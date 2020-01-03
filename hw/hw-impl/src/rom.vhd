LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY ROM IS
	PORT (
		rst             : in  std_logic; -- asynchronous reset
	  clk             : in  std_logic; -- system clock
		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_address     : in  std_logic_vector(15 downto 1);
		bus_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : in  std_logic; -- when set to '1', the bus operation is requested
		bus_acknowledge : out std_logic  -- when set to '1', the bus operation is acknowledged
	);
END ENTITY ROM;

use work.generated.all;

ARCHITECTURE rtl OF ROM IS
begin

  p0 : PROCESS(clk, rst)
  BEGIN
  if rst = '0' then
    bus_acknowledge <= '0';
  else
    if rising_edge(clk) then
      bus_data_out <= builtin_rom(bus_address);
      bus_acknowledge <= bus_request;
    end if;
  end if;
  END PROCESS;

end architecture;