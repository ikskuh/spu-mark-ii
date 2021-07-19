LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FastRAM IS
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
END ENTITY FastRAM;

ARCHITECTURE rtl OF FastRAM IS
  component fastram_ebr is
    port (
      Clock: in  std_logic; 
      ClockEn: in  std_logic; 
      Reset: in  std_logic; 
      ByteEn: in  std_logic_vector(1 downto 0); 
      WE: in  std_logic; 
      Address: in  std_logic_vector(11 downto 0); 
      Data: in  std_logic_vector(15 downto 0); 
      Q: out  std_logic_vector(15 downto 0)
    );
  end component fastram_ebr;

  SIGNAL acknext : boolean;

begin

  fastram_ebr0: FastRam_EBR
    PORT MAP(
      Clock => clk,
      ClockEn => bus_request,
      Reset => '0', -- reset for RAM doesn't do anything useful anyways
      WE => bus_write,
      ByteEn => bus_bls,
      Address => bus_address(12 downto 1),
      Data => bus_data_in,
      Q => bus_data_out
    );

  p0 : PROCESS(clk, rst)
  BEGIN
  if rst = '0' then
    bus_acknowledge <= '0';
    acknext <= False;
  else
    if rising_edge(clk) then
      acknext <= bus_request = '1';
      bus_acknowledge <= '1' when acknext else '0';
    end if;
  end if;
  END PROCESS;

end architecture;