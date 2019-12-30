
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

use work.rom.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

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

	SIGNAL rst :  std_logic := '1';
	SIGNAL clk :  std_logic := '0';
	SIGNAL bus_data_out :  std_logic_vector(15 downto 0);
	SIGNAL bus_data_in :  std_logic_vector(15 downto 0);
	SIGNAL bus_address :  std_logic_vector(15 downto 1);
	SIGNAL bus_write :  std_logic;
	SIGNAL bus_bls :  std_logic_vector(1 downto 0);
	SIGNAL bus_request :  std_logic;
	SIGNAL bus_acknowledge :  std_logic;


	SUBTYPE CPU_WORD IS std_logic_vector(15 downto 0);
	
	CONSTANT NUL : CPU_WORD := "0000000000000000";

	CONSTANT INP_ZERO : std_logic_vector(1 downto 0) := "00";
	CONSTANT INP_IMM  : std_logic_vector(1 downto 0) := "01";
	CONSTANT INP_PEEK : std_logic_vector(1 downto 0) := "10";
	CONSTANT INP_POP  : std_logic_vector(1 downto 0) := "11";

	CONSTANT OUT_DISCARD : std_logic_vector(1 downto 0) := "00";
	CONSTANT OUT_PUSH    : std_logic_vector(1 downto 0) := "01";
	CONSTANT OUT_JMP     : std_logic_vector(1 downto 0) := "10";
	CONSTANT OUT_RJMP    : std_logic_vector(1 downto 0) := "11";

	CONSTANT CON_ALWAYS  : std_logic_vector(2 downto 0) := "000";
	CONSTANT CON_ZERO    : std_logic_vector(2 downto 0) := "001";
	CONSTANT CON_NONZERO : std_logic_vector(2 downto 0) := "010";
	CONSTANT CON_GZ      : std_logic_vector(2 downto 0) := "011";
	CONSTANT CON_LZ      : std_logic_vector(2 downto 0) := "100";
	CONSTANT CON_GEZ     : std_logic_vector(2 downto 0) := "101";
	CONSTANT CON_LEZ     : std_logic_vector(2 downto 0) := "110";

	CONSTANT FLAG_NO     : std_logic_vector(0 downto 0) := "0";
	CONSTANT FLAG_YES    : std_logic_vector(0 downto 0) := "1";

	CONSTANT CMD_COPY    : std_logic_vector(4 downto 0) := "00000";
	CONSTANT CMD_IPGET   : std_logic_vector(4 downto 0) := "00001"; -- EXEC_IPGET; -- ipget
	CONSTANT CMD_GET     : std_logic_vector(4 downto 0) := "00010"; -- EXEC_GET; -- get 
	CONSTANT CMD_SET     : std_logic_vector(4 downto 0) := "00011"; -- EXEC_SET; -- set
	CONSTANT CMD_STORE8  : std_logic_vector(4 downto 0) := "00100"; -- EXEC_STORE8; -- store8
	CONSTANT CMD_STORE16 : std_logic_vector(4 downto 0) := "00101"; -- EXEC_STORE16; -- store16
	CONSTANT CMD_LOAD8   : std_logic_vector(4 downto 0) := "00110"; -- EXEC_LOAD8; -- load8
	CONSTANT CMD_LOAD16  : std_logic_vector(4 downto 0) := "00111"; -- EXEC_LOAD16; -- load16
	-- CONSTANT CMD_ : CPU_WORD := "01000"; -- RESET;           -- RESERVED
	-- CONSTANT CMD_ : CPU_WORD := "01001"; -- RESET;           -- RESERVED
	CONSTANT CMD_FRGET   : std_logic_vector(4 downto 0) := "01010"; -- EXEC_FRGET; -- frget
	CONSTANT CMD_FRSET   : std_logic_vector(4 downto 0) := "01011"; -- EXEC_FRSET; -- frset
	CONSTANT CMD_BPGET   : std_logic_vector(4 downto 0) := "01100"; -- EXEC_BPGET; -- bpget
	CONSTANT CMD_BPSET   : std_logic_vector(4 downto 0) := "01101"; -- EXEC_BPSET; -- bpset
	CONSTANT CMD_SPGET   : std_logic_vector(4 downto 0) := "01110"; -- EXEC_SPGET; -- spget
	CONSTANT CMD_SPSET   : std_logic_vector(4 downto 0) := "01111"; -- EXEC_SPSET; -- spset
	CONSTANT CMD_ADD     : std_logic_vector(4 downto 0) := "10000"; -- EXEC_ADD;        -- add
	CONSTANT CMD_SUB     : std_logic_vector(4 downto 0) := "10001"; -- EXEC_SUB;        -- sub
	CONSTANT CMD_MUL     : std_logic_vector(4 downto 0) := "10010"; -- EXEC_MUL; -- mul
	CONSTANT CMD_DIV     : std_logic_vector(4 downto 0) := "10011"; -- EXEC_DIV; -- div
	CONSTANT CMD_MOD     : std_logic_vector(4 downto 0) := "10100"; -- EXEC_MOD; -- mod
	CONSTANT CMD_AND     : std_logic_vector(4 downto 0) := "10101"; -- EXEC_AND; -- and
	CONSTANT CMD_OR      : std_logic_vector(4 downto 0) := "10110"; -- EXEC_OR; -- or
	CONSTANT CMD_XOR     : std_logic_vector(4 downto 0) := "10111"; -- EXEC_XOR; -- xor
	CONSTANT CMD_NOT     : std_logic_vector(4 downto 0) := "11000"; -- EXEC_NOT; -- not
	CONSTANT CMD_NEG     : std_logic_vector(4 downto 0) := "11001"; -- EXEC_NEG; -- neg
	CONSTANT CMD_ROL     : std_logic_vector(4 downto 0) := "11010"; -- EXEC_ROL; -- rol
	CONSTANT CMD_ROR     : std_logic_vector(4 downto 0) := "11011"; -- EXEC_ROR; -- ror
	CONSTANT CMD_BSWAP   : std_logic_vector(4 downto 0) := "11100"; -- EXEC_BSWAP; -- bswap
	CONSTANT CMD_ASR     : std_logic_vector(4 downto 0) := "11101"; -- EXEC_ASR; -- asr
	CONSTANT CMD_LSL     : std_logic_vector(4 downto 0) := "11110"; -- EXEC_LSL; -- lsl
	CONSTANT CMD_LSR     : std_logic_vector(4 downto 0) := "11111"; -- EXEC_LSR; -- lsr

	TYPE RAM_Type IS ARRAY(0 to 31) OF std_logic_vector(15 downto 0);

	SIGNAL simulated_ram : RAM_Type;


BEGIN

-- Please check and add your generic clause manually
	uut: SPU_Mark_II PORT MAP(
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


-- *** Test Bench - User Defined Section ***

	clk <= not clk  after 20 ns;  -- 25 MHz Taktfrequenz
	rst <= '0', '1' after 100 ns; -- erzeugt Resetsignal: --__

	tb : PROCESS(clk, rst)
		variable temp : std_logic_vector(15 downto 0);
	BEGIN
		if rst = '0' then
			bus_acknowledge <= '0';
		else
			if rising_edge(clk) then
				if bus_request = '1' then
					bus_acknowledge <= '1';
					if bus_write = '1' then
						if bus_address(15) = '1' then
							simulated_ram(to_integer(unsigned(bus_address(6 downto 1)))) <= bus_data_out;
						end if;
						-- report "bus write at " & to_hstring(unsigned(bus_address & "0")) & " <= " ; -- & to_hstring(unsigned(bus_data_out));
						-- ignore writes
					else 
						if bus_address(15) = '1' then
							temp := simulated_ram(to_integer(unsigned(bus_address(6 downto 1))));
						else
							temp := builtin_rom(bus_address);
						end if;
						bus_data_in <= temp;
						-- report "bus read at " & to_hstring(unsigned(bus_address & "0")) & " => " & to_hstring(unsigned(temp));
					end if;
				else
					bus_acknowledge <= '0';
				end if;
			end if;
		end if;
	END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
