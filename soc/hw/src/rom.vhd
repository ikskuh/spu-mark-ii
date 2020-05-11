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
  component boot_rom
  port (
    Address: in  std_logic_vector(9 downto 0); 
    OutClock: in  std_logic; 
    OutClockEn: in  std_logic; 
    Reset: in  std_logic; 
    Q: out  std_logic_vector(15 downto 0)
  );
  end component;

  component dist_boot_rom
    port (
      Address: in  std_logic_vector(9 downto 0); 
      Q: out  std_logic_vector(15 downto 0)
    );
  end component;

  SIGNAL acknext : boolean;
begin

  -- ebr_rom : boot_rom
  --   port map (
  --     Address(9 downto 0) => bus_address(10 downto 1), 
  --     OutClock            => clk,
  --     OutClockEn          => '1',
  --     Reset               => not rst,
  --     Q(15 downto 0)      => bus_data_out
  --   );

  dist_rom : dist_boot_rom
    port map (
      Address(9 downto 0) => bus_address(10 downto 1),
      Q(15 downto 0)      => bus_data_out
    );

  p0 : PROCESS(clk, rst)
  BEGIN
  if rst = '0' then
    bus_acknowledge <= '0';
    acknext <= False;
  else
    if rising_edge(clk) then
      bus_acknowledge <= bus_request;
      -- acknext <= bus_request = '1';
      -- bus_acknowledge <= '1' when acknext else '0';
    end if;
  end if;
  END PROCESS;

end architecture;