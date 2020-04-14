-- System-On-A-Chip definition

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SOC IS
	PORT (
		leds          : out   std_logic_vector(7 downto 0);
		switches      : in    std_logic_vector(3 downto 0);
		extclk        : in    std_logic;
		extrst        : in    std_logic;
		uart0_rxd     : in    std_logic;
		uart0_txd     : out   std_logic;
		sram_addr     : out   std_logic_vector(18 downto 0);
		sram_data     : inout std_logic_vector(7 downto 0);
		sram_we       : out   std_logic;
		sram_oe       : out   std_logic;
		sram_ce       : out   std_logic;
		dbg_miso_clk  : in    std_logic;
		dbg_miso_data : in    std_logic;
		dbg_mosi_clk  : out   std_logic;
		dbg_mosi_data : out   std_logic
	);
END ENTITY SOC;

use work.generated.all;

ARCHITECTURE rtl OF SOC IS


	COMPONENT DebugPortReceiver IS
		PORT (
			clk      : in  std_logic;
			rst      : in  std_logic;
			dbg_clk  : in  std_logic;
			dbg_data : in  std_logic;
			rcv_data : out std_logic_vector(7 downto 0);
			rcv      : out std_logic
		);
	END COMPONENT;

	COMPONENT DebugPortSender IS
	GENERIC (
		freq_clk     : natural;
		baud         : natural := 9600
	);
	PORT (
		clk      : in  std_logic;
		rst      : in  std_logic;
		dbg_clk  : out std_logic;
		dbg_data : out std_logic;
		txd_data : in std_logic_vector(7 downto 0);
		txd      : in std_logic;
    complete : out std_logic
	);
	END COMPONENT DebugPortSender;

	SIGNAL rst, clk : std_logic;

	SIGNAL led_state : std_logic_vector(7 downto 0);

	SIGNAL dbg_data_tick : std_logic;
BEGIN	
	rst <= extrst;
	clk <= extclk;

	leds(7 downto 0) <= not led_state;

	dbg_in0: DebugPortReceiver PORT MAP (
		rst => rst,
		clk => clk,	
		dbg_clk => dbg_miso_clk,
		dbg_data => dbg_miso_data,
		rcv_data => led_state,
		rcv => dbg_data_tick
	);

	dbg_out0: DebugPortSender
		GENERIC MAP (
			freq_clk => 12_000_000, -- MHz
			baud     =>     19_200  -- Baud
		)
		PORT MAP (
			rst => rst,
			clk => clk,	
			dbg_clk => dbg_mosi_clk,
			dbg_data => dbg_mosi_data,
			txd_data => led_state,
			txd => dbg_data_tick,
			complete => open
		)
	;

END ARCHITECTURE rtl ;