-- SOC Testbench
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench_spu IS
END testbench_spu;

ARCHITECTURE behavior OF testbench_spu IS 
	COMPONENT SOC IS
	PORT (
		leds      : out std_logic_vector(7 downto 0);
		switches  : in  std_logic_vector(3 downto 0);
		extclk    : in  std_logic;
		extrst    : in  std_logic;
		uart0_rxd : in  std_logic;
		uart0_txd : out std_logic;
		sram_addr : out std_logic_vector(18 downto 0);
		sram_data : inout std_logic_vector(7 downto 0);
		sram_we   : out std_logic;
		sram_oe   : out std_logic;
		sram_ce   : out std_logic
	);
	END COMPONENT SOC;

	SIGNAL rst :  std_logic := '1';
	SIGNAL clk :  std_logic := '0';
	
	SIGNAL first_access : boolean := false;

	SIGNAL sram_addr : std_logic_vector(18 downto 0);
	SIGNAL sram_data : std_logic_vector(7 downto 0);
	SIGNAL sram_we   : std_logic;
	SIGNAL sram_oe   : std_logic;
	SIGNAL sram_ce   : std_logic;
BEGIN

	glue: SOC
		PORT MAP (
			leds      => open,
			switches  => "0000",
			extclk    => clk,
			extrst    => rst,
			uart0_rxd => '0',
			uart0_txd => open,
			sram_addr => sram_addr,
			sram_data => sram_data,
			sram_we   => sram_we,
			sram_oe   => sram_oe,
			sram_ce   => sram_ce
		);
	
	clk <= not clk  after 41.666666 ns;  -- 12 MHz Taktfrequenz
	rst <= '0', '1' after 40 ns; -- erzeugt Resetsignal: --
	
	sram_fake: process(sram_oe)
	begin
		if sram_oe = '0' then
			sram_data <= "10101010";
		else
			sram_data <= "ZZZZZZZZ";
		end if;
	end process;

END;
