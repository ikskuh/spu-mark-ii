
-- VHDL Test Bench Created from source file FIFO.vhd -- Tue Dec 31 12:34:46 2019

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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT FIFO
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		input : IN std_logic;
		insert : IN std_logic;
		remove : IN std_logic;          
		output : OUT std_logic;
		empty : OUT std_logic;
		full : OUT std_logic
		);
	END COMPONENT;

	SIGNAL rst :  std_logic;
	SIGNAL clk :  std_logic;
	SIGNAL input :  std_logic;
	SIGNAL output :  std_logic;
	SIGNAL insert :  std_logic;
	SIGNAL remove :  std_logic;
	SIGNAL empty :  std_logic;
	SIGNAL full :  std_logic;

BEGIN

-- Please check and add your generic clause manually
	uut: FIFO PORT MAP(
		rst => rst,
		clk => clk,
		input => input,
		output => output,
		insert => insert,
		remove => remove,
		empty => empty,
		full => full
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
