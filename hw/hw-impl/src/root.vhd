LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY root IS
	PORT (
		leds          : out std_logic_vector(7 downto 0);
		switches      : in  std_logic_vector(3 downto 0);
		extclk        : in  std_logic;
		extrst        : in  std_logic;
		uart0_rxd     : in  std_logic;
		uart0_txd     : out std_logic;
		sram_addr     : out std_logic_vector(18 downto 0);
		sram_data     : inout std_logic_vector(7 downto 0);
		sram_we       : out std_logic;
		sram_oe       : out std_logic;
		sram_ce       : out std_logic;
		clk_dbg       : out std_logic;
		dbg_miso_clk  : in  std_logic;
		dbg_miso_data : in  std_logic;
		dbg_mosi_clk  : out std_logic;
		dbg_mosi_data : out std_logic
	);
	
END ENTITY root;

use work.generated.all;

ARCHITECTURE rtl OF root IS
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
			sram_ce   : out std_logic;
			dbg_miso_clk  : in  std_logic;
			dbg_miso_data : in  std_logic;
			dbg_mosi_clk  : out std_logic;
			dbg_mosi_data : out std_logic
		);
	END COMPONENT SOC;
BEGIN
	clk_dbg <= extclk;
	glue: SOC
		PORT MAP (
			leds          => leds,
			switches      => switches,
			extclk        => extclk,
			extrst        => extrst,
			uart0_rxd     => uart0_rxd,
			uart0_txd     => uart0_txd,
			sram_addr     => sram_addr,
			sram_data     => sram_data,
			sram_we       => sram_we,
			sram_oe       => sram_oe,
			sram_ce       => sram_ce,
			dbg_miso_clk  => dbg_miso_clk ,
			dbg_miso_data => dbg_miso_data,
			dbg_mosi_clk  => dbg_mosi_clk ,
			dbg_mosi_data => dbg_mosi_data
		);
	
END ARCHITECTURE rtl ;