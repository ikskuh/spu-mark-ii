
library IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity fastram_ebr is
  port (
      Clock: in  std_logic; 
      ClockEn: in  std_logic; 
      Reset: in  std_logic; 
      ByteEn: in  std_logic_vector(1 downto 0); 
      WE: in  std_logic; 
      Address: in  std_logic_vector(11 downto 0); 
      Data: in  std_logic_vector(15 downto 0); 
      Q: out  std_logic_vector(15 downto 0));
end fastram_ebr;

ARCHITECTURE rtl OF fastram_ebr IS

  TYPE RAM_Type IS ARRAY(0 to 4096) OF std_logic_vector(15 downto 0);

  SIGNAL backing_buffer : RAM_Type;
begin

  p0 : PROCESS(Clock, Reset)
  BEGIN
  if rising_edge(Clock) then
    if ClockEn = '1' then
      if WE = '1' then
        case ByteEn is
          -- Only write to the portion of the register
          -- that is selected by BLS
          when "11" => backing_buffer(to_integer(unsigned(Address))) <= Data;
          when "01" => backing_buffer(to_integer(unsigned(Address)))(7 downto 0) <= Data(7 downto 0);
          when "10" => backing_buffer(to_integer(unsigned(Address)))(15 downto 8) <= Data(15 downto 8);
          when others => -- ignore
        end case;
      end if;
      -- We don't need to respect `bus_bls` here as
      -- we don't modify any data.
      Q <= backing_buffer(to_integer(unsigned(Address)));
   end if;
  end if;
  END PROCESS;

end architecture;
