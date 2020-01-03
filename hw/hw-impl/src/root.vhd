LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- LIBRARY lattice;
-- USE lattice.components.all;
 
-- LIBRARY machxo;
-- USE machxo.all;

ENTITY root IS
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
	
END ENTITY root;

use work.generated.all;

ARCHITECTURE rtl OF root IS
	COMPONENT SPU_Mark_II
	PORT(
		rst             : IN std_logic;
		clk             : IN std_logic;
		bus_data_in     : IN std_logic_vector(15 downto 0);
		bus_acknowledge : IN std_logic;          
		bus_data_out    : OUT std_logic_vector(15 downto 0);
		bus_address     : OUT std_logic_vector(15 downto 1);
		bus_write       : OUT std_logic;
		bus_bls         : OUT std_logic_vector(1 downto 0);
		bus_request     : OUT std_logic
		);
	END COMPONENT;

	COMPONENT Register_RAM IS
		GENERIC (
			address_width : natural := 8   -- number of address bits => 2**address_width => number of bytes
		);

		PORT (
			rst             : in  std_logic; -- asynchronous reset
			clk             : in  std_logic; -- system clock
			bus_data_out    : out std_logic_vector(15 downto 0);
			bus_data_in     : in  std_logic_vector(15 downto 0);
			bus_address     : in std_logic_vector(address_width-1 downto 1);
			bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
			bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
			bus_request     : in std_logic; -- when set to '1', the bus operation is requested
			bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
		);
	
	END COMPONENT Register_RAM;

	COMPONENT Serial_Port IS
		GENERIC (
			clkfreq  : natural; -- frequency of 'clk' in Hz
			baudrate : natural  -- basic symbol rate of the UART ("bit / sec")
		);
		PORT (
			rst             : in  std_logic; -- asynchronous reset
			clk             : in  std_logic; -- system clock
			uart_txd        : out std_logic;
			uart_rxd        : in  std_logic;
			bus_data_out    : out std_logic_vector(15 downto 0);
			bus_data_in     : in  std_logic_vector(15 downto 0);
			bus_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
			bus_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
			bus_request     : in  std_logic; -- when set to '1', the bus operation is requested
			bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
		);
	END COMPONENT Serial_Port;

	COMPONENT ROM IS
	PORT (
		rst             : in  std_logic; -- asynchronous reset
		clk             : in  std_logic; -- system clock
		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_address     : in std_logic_vector(15 downto 1);
		bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : in std_logic; -- when set to '1', the bus operation is requested
		bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
	);
	END COMPONENT ROM;

	SIGNAL bus_data_out :  std_logic_vector(15 downto 0) := "0000000000000000";
	SIGNAL bus_data_in :  std_logic_vector(15 downto 0);
	SIGNAL bus_address :  std_logic_vector(15 downto 1) := "000000000000000";
	SIGNAL bus_write :  std_logic := '0';
	SIGNAL bus_bls :  std_logic_vector(1 downto 0) := "00";
	SIGNAL bus_request :  std_logic := '0';
	SIGNAL bus_acknowledge :  std_logic := '0';

	TYPE SRAM_Mode_Type IS (OFF,READ,WRITE);

	SIGNAL sram_data_in : std_logic_vector(7 downto 0);
	SIGNAL sram_data_out : std_logic_vector(7 downto 0);
	SIGNAL sram_mode : SRAM_Mode_Type := off;
	
	
	SIGNAL ram0_select : std_logic;
	SIGNAL ram0_ack : std_logic;
	SIGNAL ram0_out : std_logic_vector(15 downto 0);

	SIGNAL uart0_select : std_logic;
	SIGNAL uart0_ack : std_logic;
	SIGNAL uart0_out : std_logic_vector(15 downto 0);

	SIGNAL rom0_select : std_logic;
	SIGNAL rom0_ack : std_logic;
	SIGNAL rom0_out : std_logic_vector(15 downto 0);

	SIGNAL rst : std_logic;
	SIGNAL clk : std_logic;

	SIGNAL clkdiv : unsigned(7 downto 0) := to_unsigned(0, 8);

BEGIN	
	rst <= extrst;
	clk <= extclk;

	-- proc_clkdiv: process (clk,rst)
	-- begin
	-- 	if rst = '0' then
	-- 		clk <= '0';
	-- 		clkdiv <= to_unsigned(0, 8);
	-- 	elsif rising_edge(clk) then
	-- 		if clkdiv = 0 then
	-- 			clkdiv <= to_unsigned(99, 8);
	-- 			clk <= not clk;
	-- 		else
	-- 			clkdiv <= clkdiv - 1;
	-- 		end if;
	-- 	end if;
	-- end process;

		sram_data_in <= sram_data;
		sram_data <= sram_data_out when sram_mode = write else "ZZZZZZZZ";
	
		sram_data_out <= (others => '0');
		sram_addr <= (others => '0');

		sram_we <= '0' when sram_mode = write else '1';
		sram_oe <= '0' when sram_mode = read else '1';
		sram_ce <= '0' when sram_mode /= off else '1';

	cpu: SPU_Mark_II PORT MAP(
		rst => rst,
		clk => clk,
		bus_data_out => bus_data_out,
		bus_data_in => bus_data_in,
		bus_address => bus_address,
		bus_write => bus_write,
		bus_bls => bus_bls,
		bus_request => bus_request,
		bus_acknowledge => bus_acknowledge
	);
	
	ram0 : Register_RAM
		GENERIC MAP (address_width => 5)
		PORT MAP (
			rst             => rst,
			clk             => clk,
			bus_data_out    => ram0_out,
			bus_data_in     => bus_data_out,
			bus_address     => bus_address(4 downto 1),
			bus_write       => bus_write,
			bus_bls         => bus_bls,
			bus_request     => ram0_select,
			bus_acknowledge => ram0_ack
		);

	uart0 : Serial_Port
		GENERIC MAP (clkfreq  => 12_000_000, baudrate => 19200)
		PORT MAP (
			rst             => rst,
			clk             => clk,
			uart_txd        => uart0_txd,
			uart_rxd        => uart0_rxd,
			bus_data_out    => uart0_out,
			bus_data_in     => bus_data_out,
			bus_write       => bus_write,
			bus_bls         => bus_bls,
		bus_request     => uart0_select,
			bus_acknowledge => uart0_ack
		);
	
	rom0 : ROM
		PORT MAP (
			rst             => rst,
			clk             => clk,
			bus_data_out    => rom0_out,
			bus_data_in     => bus_data_out,
			bus_address     => bus_address,
			bus_write       => bus_write,
			bus_bls         => bus_bls,
			bus_request     => rom0_select,
			bus_acknowledge => rom0_ack
		);

	rom0_select  <= bus_request when bus_address(15 downto 14) = "00" else '0'; -- 0x0***
	uart0_select <= bus_request when bus_address(15 downto 14) = "01" else '0'; -- 0x4***
	ram0_select  <= bus_request when bus_address(15)           = '1'  else '0'; -- 0x8***

	bus_acknowledge <= rom0_ack  when bus_address(15 downto 14) = "00" else
										 uart0_ack when bus_address(15 downto 14) = "01" else
										 ram0_ack  when bus_address(15)           = '1'  else
										 '0';
										
	 bus_data_in <= rom0_out  when bus_address(15 downto 14) = "00" else
	 							 uart0_out when bus_address(15 downto 14) = "01" else
	 							 ram0_out  when bus_address(15)           = '1'  else
	 							 "0000000000000000";
	
	p0: process(clk, rst)
	begin
		if rising_edge(clk) then
			leds(6 downto 0) <= (not bus_address(7 downto 1)) when bus_request = '1' else "1111111";
			leds(7)          <= not bus_request;
		end if;
	end process;
	
END ARCHITECTURE rtl ;