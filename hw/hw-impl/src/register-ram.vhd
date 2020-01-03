LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Register_RAM IS
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
	
END ENTITY Register_RAM;

ARCHITECTURE rtl OF Register_RAM IS

  TYPE RAM_Type IS ARRAY(0 to 2**address_width) OF std_logic_vector(15 downto 0);

  SIGNAL data : RAM_Type;
begin

  p0 : PROCESS(clk, rst)
  BEGIN
  if rst = '0' then
    bus_acknowledge <= '0';
  else
    if rising_edge(clk) then
      if bus_request = '1' then
        bus_acknowledge <= '1';
        if bus_write = '1' then
          case bus_bls is
            -- Only write to the portion of the register
            -- that is selected by BLS
            when "11" => data(to_integer(unsigned(bus_address))) <= bus_data_in;
            when "01" => data(to_integer(unsigned(bus_address)))(7 downto 0) <= bus_data_in(7 downto 0);
            when "10" => data(to_integer(unsigned(bus_address)))(15 downto 8) <= bus_data_in(15 downto 8);
            when others => -- ignore
          end case;
        end if;
        -- We don't need to respect `bus_bls` here as
        -- we don't modify any data.
        bus_data_out <= data(to_integer(unsigned(bus_address)));
      else
        bus_acknowledge <= '0';
      end if;
    end if;
  end if;
  END PROCESS;

end architecture;