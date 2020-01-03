
-- VHDL Test Bench Created from source file SPU_Mark_II.vhd -- Mon Dec 30 13:56:57 2019

--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Lattice recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "source->import"
-- menu in the ispLEVER Project Navigator to import the testbench.
-- Then edit the user defined section below, adding code to generate the 
-- stimulus for your design.
-- 3) VHDL simulations will produce errors if there are Lattice FPGA library 
-- elements in your design that require the instantiation of GSR, PUR, and
-- TSALL and they are not present in the testbench. For more information see
-- the How To section of online help.  
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY std;
use std.textio.all;

use work.generated.all;

ENTITY testbench_spu IS
END testbench_spu;

ARCHITECTURE behavior OF testbench_spu IS 

	COMPONENT SPU_Mark_II
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		bus_data_in : IN std_logic_vector(15 downto 0);
		bus_acknowledge : IN std_logic;          
		bus_data_out : OUT std_logic_vector(15 downto 0);
		bus_address : OUT std_logic_vector(15 downto 1);
		bus_write : OUT std_logic;
		bus_bls : OUT std_logic_vector(1 downto 0);
		bus_request : OUT std_logic
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

	SIGNAL rst :  std_logic := '1';
	SIGNAL clk :  std_logic := '0';
	SIGNAL bus_data_out :  std_logic_vector(15 downto 0);
	SIGNAL bus_data_in :  std_logic_vector(15 downto 0);
	SIGNAL bus_address :  std_logic_vector(15 downto 1);
	SIGNAL bus_write :  std_logic;
	SIGNAL bus_bls :  std_logic_vector(1 downto 0);
	SIGNAL bus_request :  std_logic;
	SIGNAL bus_acknowledge :  std_logic;

	SIGNAL first_access : boolean := false;

	SIGNAL ram0_select : std_logic := '0';
	SIGNAL ram0_ack : std_logic := '0';
	SIGNAL ram0_out : std_logic_vector(15 downto 0);

	SIGNAL uart0_select : std_logic := '0';
	SIGNAL uart0_ack : std_logic := '0';
	SIGNAL uart0_out : std_logic_vector(15 downto 0);

	SIGNAL rom0_select : std_logic := '0';
	SIGNAL rom0_ack : std_logic := '0';
	SIGNAL rom0_out : std_logic_vector(15 downto 0);

	SIGNAL uart0_txd : std_logic;

BEGIN

	uut: SPU_Mark_II
		PORT MAP(
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
		GENERIC MAP (address_width => 8)
		PORT MAP (
			rst             => rst,
			clk             => clk,
			bus_data_out    => ram0_out,
			bus_data_in     => bus_data_out, -- must be muxed!
			bus_address     => bus_address(7 downto 1),
			bus_write       => bus_write,
			bus_bls         => bus_bls,
			bus_request     => ram0_select,
			bus_acknowledge => ram0_ack
		);

	uart0 : Serial_Port
		GENERIC MAP (clkfreq  => 12_000_000, baudrate => 1_920_000)
		PORT MAP (
			rst             => rst,
			clk             => clk,
			uart_txd        => uart0_txd,
			uart_rxd        => '1',
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
			bus_data_in     => bus_data_out, -- must be muxed!
			bus_address     => bus_address,
			bus_write       => bus_write,
			bus_bls         => bus_bls,
			bus_request     => rom0_select,
			bus_acknowledge => rom0_ack
		);
	
	clk <= not clk  after 83.333 ns;  -- 12 MHz Taktfrequenz
	rst <= '0', '1' after 100 ns; -- erzeugt Resetsignal: --

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


	tb : PROCESS(clk, rst)
		variable temp : std_logic_vector(15 downto 0);
	BEGIN
		if rst = '0' then
			
		else
			if rising_edge(clk) then
				if bus_request = '1' then
					if bus_write = '1' then
						if first_access then
							-- report "bus write at " & to_hstring(unsigned(bus_address) & "0") & " <= " & to_hstring(unsigned(bus_data_out));
						end if;
					else 
						if not first_access then
							-- report "bus read at " & to_hstring(unsigned(bus_address) & "0") & " => " & to_hstring(unsigned(bus_data_in));						
						end if;
					end if;
					first_access <= false;
				else
					first_access <= true;
				end if;
			end if;
		end if;
	END PROCESS;

-- *** End Test Bench - User Defined Section ***

END;
