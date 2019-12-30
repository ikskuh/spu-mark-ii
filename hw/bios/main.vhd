LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

package ROM is

  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector;

end package;

package body ROM is

  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector is
  begin
    case to_integer(unsigned(addr & "0")) is
      when 16#0000# => return "0000001000010000";
      when 16#0002# => return "0000000000001000";
      when 16#0008# => return "0000001000010000";
      when others   => return "0000000000000000";
    end case;
  end function;

end package body;
