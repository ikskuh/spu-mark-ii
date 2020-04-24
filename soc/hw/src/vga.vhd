-- # 320x240 59.52 Hz (CVT 0.08M3) hsync: 15.00 kHz; pclk: 6.00 MHz
--                             pclk  width hstart hend   hlimit  height vstart vend vlimit pol 
-- Modeline "320x240_60.00"    6.00  320   336    360    400     240    243    247  252    -hsync +vsync

-- Pin Assignments:
-- R         lila        F14
-- G         grau        C15
-- B         weiß        E14
-- R-GND     schwarz 
-- G-GND     braun
-- B-GND     rot
-- S-GND     orange
-- HS        gelb        B7
-- VS        grün        A5

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY VGA_Driver IS
	PORT (
    clk           : in  std_logic;
    rst           : in  std_logic;
		vga_r         : out std_logic;
		vga_g         : out std_logic;
		vga_b         : out std_logic;
		vga_hs        : out std_logic;
		vga_vs        : out std_logic
	);
	
END ENTITY VGA_Driver;

ARCHITECTURE rtl OF VGA_Driver IS

	CONSTANT vga_hsize    : natural := 320;
	CONSTANT vga_hs_start : natural := 336;
	CONSTANT vga_hs_end   : natural := 360;
	CONSTANT vga_hlimit   : natural := 400;
	
	CONSTANT vga_vsize    : natural := 240;
	CONSTANT vga_vs_start : natural := 243;
	CONSTANT vga_vs_end   : natural := 247;
	CONSTANT vga_vlimit   : natural := 252;
	
	SIGNAL vga_col : unsigned(8 downto 0);
	SIGNAL vga_row : unsigned(7 downto 0);

	SIGNAL vga_div : unsigned(0 downto 0);
BEGIN
	vga_proc : process(rst, clk)
	begin
		if rst = '0' then
			vga_col <= to_unsigned(0, vga_col'length);
			vga_row <= to_unsigned(0, vga_row'length);
			vga_div <= to_unsigned(0, vga_div'length);
		elsif rising_edge(clk) then

			if vga_div = 0 then

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

				if vga_col < vga_hsize and vga_row < vga_vsize then
					-- Simple pixel pattern here
					vga_r <= std_logic(vga_col(0));
					vga_g <= std_logic(vga_col(1));
					vga_b <= std_logic(vga_col(2));
				else
					vga_r <= '0'; -- all black
					vga_g <= '0'; -- all black
					vga_b <= '0'; -- all black
				end if;

				vga_hs <= '1' when vga_col >= vga_hs_start and vga_col <= vga_hs_end else '0';
				vga_vs <= '1' when vga_row >= vga_vs_start and vga_row <= vga_vs_end else '0';

				vga_div <= to_unsigned(1, vga_div'length); -- divide by 2
			else	
				vga_div <= vga_div - 1;
			end if;
		end if;

	end process;

END ARCHITECTURE rtl ;