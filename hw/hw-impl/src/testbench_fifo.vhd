LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY std;
use std.textio.all;

use work.generated.all;

ENTITY testbench_fifo IS
END testbench_fifo;

ARCHITECTURE behavior OF testbench_fifo IS 
	COMPONENT FIFO IS
		GENERIC (
			width : natural := 16; -- width in bits
			depth : natural := 8  -- number of elements in the fifo
		);
		PORT (
			rst             : in  std_logic; -- asynchronous reset
			clk             : in  std_logic; -- system clock
			input           : in  std_logic_vector(width - 1 downto 0);
			output          : out std_logic_vector(width - 1 downto 0);
			insert          : in  std_logic;
			remove          : in  std_logic;
			empty           : out std_logic;
			full            : out std_logic;
			not_empty       : out std_logic
		);
	END COMPONENT FIFO;

	SIGNAL rst :  std_logic := '1';
	SIGNAL clk :  std_logic := '0';
	
	SIGNAL fifo_input     : std_logic_vector(3 downto 0);
	SIGNAL fifo_output    : std_logic_vector(3 downto 0);
	SIGNAL fifo_insert    : std_logic := '0';
	SIGNAL fifo_remove    : std_logic := '0';
	SIGNAL fifo_full      : std_logic := '0';
	SIGNAL fifo_empty     : std_logic := '0';
	SIGNAL fifo_not_empty : std_logic := '0';
BEGIN
	fifo0: FIFO GENERIC MAP(
		width => 4,
		depth => 4
	) PORT MAP (
		rst => rst,
		clk => clk,
		input     => fifo_input,
		output    => fifo_output,
		insert    => fifo_insert,
		remove    => fifo_remove,
		empty     => fifo_empty,
		full      => fifo_full,
		not_empty => fifo_not_empty

	);

	clk <= not clk  after 10  ns; -- 100 MHz Taktfrequenz
	rst <= '0', '1' after 100 ns; -- erzeugt Resetsignal:

	tb : PROCESS
	BEGIN

		wait for 120 ns;

		fifo_input <= "0001";
		fifo_insert <= '1';
		wait for 20 ns;
		fifo_insert <= '0';
		wait for 20 ns;

		fifo_input <= "0010";
		fifo_insert <= '1';
		wait for 20 ns;
		fifo_insert <= '0';
		wait for 20 ns;

		fifo_input <= "0011";
		fifo_insert <= '1';
		wait for 20 ns;
		fifo_insert <= '0';
		wait for 20 ns;

		fifo_input <= "0100";
		fifo_insert <= '1';
		wait for 20 ns;
		fifo_insert <= '0';
		wait for 20 ns;

		fifo_input <= "0101";
		fifo_insert <= '1';
		wait for 20 ns;
		fifo_insert <= '0';
		wait for 20 ns;
		
		-- start to clear the fifo

		fifo_remove <= '1';
		wait for 20 ns;
		fifo_remove <= '0';

		wait;
	END PROCESS;

-- *** End Test Bench - User Defined Section ***

END;
