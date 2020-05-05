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
		dbg_miso_data : in  std_logic;
		dbg_mosi_data : out std_logic;
		vga_r         : out std_logic_vector(1 downto 0);
		vga_g         : out std_logic_vector(1 downto 0);
		vga_b         : out std_logic_vector(1 downto 0);
		vga_hs        : out std_logic;
		vga_vs        : out std_logic;
		logic_dbg     : out std_logic_vector(7 downto 0)
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
			dbg_miso_data : in  std_logic;
			dbg_mosi_data : out std_logic;
			logic_dbg     : out std_logic_vector(7 downto 0)
		);
	END COMPONENT SOC;

	COMPONENT VGA_Driver IS
	PORT (
		clk           : in  std_logic;
		rst           : in  std_logic;
		vga_r         : out std_logic_vector(1 downto 0);
		vga_g         : out std_logic_vector(1 downto 0);
		vga_b         : out std_logic_vector(1 downto 0);
		vga_hs        : out std_logic;
		vga_vs        : out std_logic
	);
	END COMPONENT VGA_Driver;

	component vga_pll
	port (CLKI: in  std_logic; CLKOP: out  std_logic; 
		LOCK: out  std_logic);
	end component;

	SIGNAL clk : std_logic;
	SIGNAL rst : std_logic;

	SIGNAL vga_hs_raw : std_logic;
	SIGNAL vga_vs_raw : std_logic;
	SIGNAL vga_color  : std_logic_vector(5 downto 0);

SIGNAL sysclk_raw : std_logic;
SIGNAL sysclk_locked : std_logic;
	
BEGIN

	rst <= extrst;
	clk <= sysclk_raw and sysclk_locked;
	
	sys_clk : vga_pll port map (
		CLKI => extclk, 
		CLKOP => sysclk_raw, 
		LOCK => sysclk_locked
	);

	vga: VGA_Driver
		PORT MAP (
			clk            => clk,
			rst            => rst,
			vga_r          => vga_r,
			vga_g          => vga_g,
			vga_b          => vga_b,
			vga_hs         => vga_hs,
			vga_vs         => vga_vs
		);

	-- leds(3 downto 0) <= not switches(3 downto 0);

	-- glue: SOC
	-- 	PORT MAP (
	-- 		leds          => leds,
	-- 		switches      => switches,
	-- 		extclk        => clk,
	-- 		extrst        => rst,
	-- 		uart0_rxd     => uart0_rxd,
	-- 		uart0_txd     => uart0_txd,
	-- 		sram_addr     => sram_addr,
	-- 		sram_data     => sram_data,
	-- 		sram_we       => sram_we,
	-- 		sram_oe       => sram_oe,
	-- 		sram_ce       => sram_ce,
	-- 		dbg_miso_data => dbg_miso_data,
	-- 		dbg_mosi_data => dbg_mosi_data,
	-- 		logic_dbg     => logic_dbg
	-- 	);

END ARCHITECTURE rtl ;