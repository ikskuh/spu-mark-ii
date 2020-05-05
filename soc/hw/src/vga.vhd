LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY VGA_Driver IS
	PORT (
    clk           : in  std_logic;
    rst           : in  std_logic;
		vga_r         : out std_logic_vector(1 downto 0);
		vga_g         : out std_logic_vector(1 downto 0);
		vga_b         : out std_logic_vector(1 downto 0);
		vga_hs        : out std_logic;
		vga_vs        : out std_logic
	);
END ENTITY VGA_Driver;

ARCHITECTURE rtl OF VGA_Driver IS
	component videoram
  port (DataInA: in  std_logic_vector(3 downto 0); 
      DataInB: in  std_logic_vector(3 downto 0); 
      AddressA: in  std_logic_vector(14 downto 0); 
      AddressB: in  std_logic_vector(14 downto 0); 
      ClockA: in  std_logic; ClockB: in  std_logic; 
      ClockEnA: in  std_logic; ClockEnB: in  std_logic; 
      WrA: in  std_logic; WrB: in  std_logic; ResetA: in  std_logic; 
      ResetB: in  std_logic; QA: out  std_logic_vector(3 downto 0); 
      QB: out  std_logic_vector(3 downto 0));
end component;

	-- # 640x480 59.38 Hz (CVT 0.31M3) hsync: 29.69 kHz; pclk: 23.75 MHz
	-- Modeline "640x480_60.00"   23.75  640 664 720 800  480 483 487 500 -hsync +vsync

	CONSTANT vga_hsize    : natural := 640;
	CONSTANT vga_hs_start : natural := 664;
	CONSTANT vga_hs_end   : natural := 720;
	CONSTANT vga_hlimit   : natural := 800;
	
	CONSTANT vga_vsize    : natural := 480;
	CONSTANT vga_vs_start : natural := 483;
	CONSTANT vga_vs_end   : natural := 487;
	CONSTANT vga_vlimit   : natural := 500;

	SIGNAL vga_col : unsigned(9 downto 0);
	SIGNAL vga_row : unsigned(9 downto 0);

	SIGNAL vga_div : unsigned(0 downto 0);

	SIGNAL vga_ram_addr  : unsigned(14 downto 0);
	SIGNAL vga_ram_color : std_logic_vector(3 downto 0);

	SIGNAL vga_color : std_logic_vector(5 downto 0);

	function fixed_color_lut(index: unsigned(3 downto 0)) return std_logic_vector(5 downto 0) is
		begin
			case to_integer(index) is
				when  0 => return "000000"; -- black
				when  1 => return "010101"; -- low gray
				when  2 => return "101010"; -- high gray
				when  3 => return "111111"; -- white
				when  4 => return "110000"; -- primary red
				when  5 => return "001100"; -- primary green
				when  6 => return "000011"; -- primary blue
				when  7 => return "111100"; -- primary yellow
				when  8 => return "001111"; -- primary cyan
				when  9 => return "110011"; -- primary magenta
				when 10 => return "010000"; -- dark red
				when 11 => return "000100"; -- dark green
				when 12 => return "000001"; -- dark blue
				when 13 => return "100011"; -- purple
				when 14 => return "110100"; -- orange
				when 15 => return "011110"; -- bright green
				when others => return "110111"; 
			end case;
		end function;
BEGIN

	vga_r <= vga_color(5 downto 4);
	vga_g <= vga_color(3 downto 2);
	vga_b <= vga_color(1 downto 0);

	vga_ram : videoram port map (
		DataInA => "0000",  -- for now...
		DataInB => "0000", 
		AddressA => "00000000000000",  -- for now...
		AddressB => std_logic_vector(vga_ram_addr),
		ClockA         => clk,
		ClockB         => clk,
		ClockEnA       => '1',
		ClockEnB       => '1',
		WrA            => '0', -- for now...
		WrB            => '0', -- don't write on the video port
		ResetA         => '0',
		ResetB         => '0',
		QA             => open, -- for now... 
		QB             => vga_ram_color
	);

	vga_proc : process(rst, clk)
		VARIABLE color : std_logic_vector(5 downto 0);

	begin
		if rst = '0' then
			vga_col      <= to_unsigned(0, vga_col'length);
			vga_row      <= to_unsigned(0, vga_row'length);
			vga_div      <= to_unsigned(0, vga_div'length);
			vga_ram_addr <= to_unsigned(0, vga_ram_addr'length);
		elsif rising_edge(clk) then
			if vga_div = 1 then -- divide by 2
				if vga_col = vga_hlimit - 1 then
					vga_col <= to_unsigned(0, vga_col'length);
					if vga_row = vga_vlimit - 1 then
						vga_row <= to_unsigned(0, vga_row'length);
					else 
						vga_row <= vga_row + 1;
					end if;
				else
					vga_col <= vga_col + 1;
				end if;

				if vga_col >= 64 and vga_col < 576 and vga_row >= 112 and vga_row < 368 then
					-- picture
					vga_color <= fixed_color_lut(vga_ram_addr(3 downto 0));

					if vga_col(0) = '1' then
						vga_ram_addr <= vga_ram_addr + 1;
					end if;
				elsif vga_col < vga_hsize and vga_row < vga_vsize then
					-- border
					vga_color <= "101010";
				else
					-- out of screen
					vga_color <= "000000"; -- all black
				end if;

				vga_hs <= '1' when vga_col >= vga_hs_start and vga_col <= vga_hs_end else '0';
				vga_vs <= '1' when vga_row >= vga_vs_start and vga_row <= vga_vs_end else '0';

				vga_div <= to_unsigned(0, vga_div'length);
			else	
				vga_div <= vga_div + 1;
			end if;
		end if;
	end process;
END ARCHITECTURE rtl ;