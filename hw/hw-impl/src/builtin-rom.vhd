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
      when 16#0000# => return "0011110000001000";
      when 16#0002# => return "1000000000100000";
      when 16#0004# => return "0000000100001000";
      when 16#0006# => return "0000000000000001";
      when 16#0008# => return "0000000100001000";
      when 16#000A# => return "0000000000000010";
      when 16#000C# => return "0100100101111000";
      when 16#000E# => return "0001010001101000";
      when 16#0010# => return "0100000000000000";
      when 16#0012# => return "0000001000001000";
      when 16#0014# => return "0000000000011100";
      when 16#001C# => return "0000001000001000";
      when 16#001E# => return "0000000000010010";
      when 16#0020# => return "0110010101001000";
      when 16#0022# => return "0110110001101100";
      when 16#0024# => return "0010110001101111";
      when 16#0026# => return "0101011100100000";
      when 16#0028# => return "0111001001101111";
      when 16#002A# => return "0110010001101100";
      when 16#002C# => return "0000000000100001";
      when others   => return "0000000000000000";
    end case;
  end function;

end package body;
