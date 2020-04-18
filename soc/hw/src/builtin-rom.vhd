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
      when 16#0002# => return "0110000000100000";
      when 16#0004# => return "0001010000101000";
      when 16#0006# => return "0100000000000000";
      when 16#0008# => return "0000000001001000";
      when 16#000A# => return "0001010000101000";
      when 16#000C# => return "0100000000000000";
      when 16#000E# => return "0000000001100101";
      when 16#0010# => return "0001010000101000";
      when 16#0012# => return "0100000000000000";
      when 16#0014# => return "0000000001101100";
      when 16#0016# => return "0001010000101000";
      when 16#0018# => return "0100000000000000";
      when 16#001A# => return "0000000001101100";
      when 16#001C# => return "0001010000101000";
      when 16#001E# => return "0100000000000000";
      when 16#0020# => return "0000000001101111";
      when 16#0022# => return "0001010000101000";
      when 16#0024# => return "0100000000000000";
      when 16#0026# => return "0000000000100001";
      when 16#0028# => return "0001010000101000";
      when 16#002A# => return "0100000000000000";
      when 16#002C# => return "0000000000001101";
      when 16#002E# => return "0001010000101000";
      when 16#0030# => return "0100000000000000";
      when 16#0032# => return "0000000000001010";
      when 16#0034# => return "0001000000101000";
      when 16#0036# => return "1000000000000000";
      when 16#003A# => return "0001100110001000";
      when 16#003C# => return "1000000000000000";
      when 16#003E# => return "0001000001001010";
      when 16#0040# => return "0100000000000000";
      when 16#0042# => return "0000000000011000";
      when 16#0044# => return "0000001000001000";
      when 16#0046# => return "0000000000111010";
      when others   => return "0000000000000000";
    end case;
  end function;

end package body;
