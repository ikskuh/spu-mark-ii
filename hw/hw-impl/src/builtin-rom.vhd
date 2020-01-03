LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

package generated is

  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector;

end package;

package body generated is

  function builtin_rom(addr : in std_logic_vector(15 downto 1)) return std_logic_vector is
  begin
    case to_integer(unsigned(addr & "0")) is
      when 16#0000# => return "0011110000001000";
      when 16#0002# => return "1000000000100000";
      when 16#0004# => return "0001010000101000";
      when 16#0006# => return "0100000000000000";
      when 16#0008# => return "0000000000100001";
      when 16#000A# => return "0000000100001000";
      when 16#000C# => return "0000000001000001";
      when 16#000E# => return "0001010001001000";
      when 16#0010# => return "0100000000000000";
      when 16#0012# => return "0000000100001000";
      when 16#0014# => return "0000000000000001";
      when 16#0016# => return "0100000101111000";
      when 16#0018# => return "0100010010110000";
      when 16#001A# => return "0000000010000000";
      when 16#001C# => return "0000000101101001";
      when 16#001E# => return "0000000000100000";
      when 16#0020# => return "0001010000101001";
      when 16#0022# => return "0100000000000000";
      when 16#0024# => return "0000000000001101";
      when 16#0026# => return "0001010000101001";
      when 16#0028# => return "0100000000000000";
      when 16#002A# => return "0000000000001010";
      when 16#002C# => return "0000001000001000";
      when 16#002E# => return "0000000000001110";
      when others   => return "0000000000000000";
    end case;
  end function;

end package body;
