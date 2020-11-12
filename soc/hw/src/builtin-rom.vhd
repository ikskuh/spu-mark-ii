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
      when 16#0000# => return "0000001000001000";
      when 16#0002# => return "0000000000000100";
      when 16#0004# => return "0001010000101000";
      when 16#0006# => return "1111000000000010";
      when 16#0008# => return "0111111100000001";
      when 16#000A# => return "0001010000101000";
      when 16#000C# => return "1111000000010000";
      when 16#000E# => return "1000000000000001";
      when 16#0010# => return "0001010000101000";
      when 16#0012# => return "1111000000010010";
      when 16#0014# => return "1000000000010001";
      when 16#0016# => return "0001010000101000";
      when 16#0018# => return "1111000000010100";
      when 16#001A# => return "1000000000100001";
      when 16#001C# => return "0001010000101000";
      when 16#001E# => return "1111000000010110";
      when 16#0020# => return "1000000000110001";
      when 16#0022# => return "0001010000101000";
      when 16#0024# => return "1111000000011000";
      when 16#0026# => return "1000000001000001";
      when 16#0028# => return "0001010000101000";
      when 16#002A# => return "1111000000011010";
      when 16#002C# => return "1000000001010001";
      when 16#002E# => return "0001010000101000";
      when 16#0030# => return "1111000000011100";
      when 16#0032# => return "1000000001100001";
      when 16#0034# => return "0001010000101000";
      when 16#0036# => return "1111000000011110";
      when 16#0038# => return "1000000001110001";
      when 16#003A# => return "0001010000101000";
      when 16#003C# => return "0001000000000100";
      when 16#003E# => return "0111111111010001";
      when 16#0040# => return "0001010000101000";
      when 16#0042# => return "0010000000000000";
      when 16#0046# => return "0001010000101000";
      when 16#0048# => return "0010000000000010";
      when 16#004A# => return "0000000010000000";
      when 16#004C# => return "0001010000101000";
      when 16#004E# => return "0001000000001110";
      when 16#0050# => return "1000000010000001";
      when 16#0052# => return "0011110000001000";
      when 16#0054# => return "1000000000000000";
      when 16#0056# => return "0011010000001000";
      when 16#0058# => return "1000000000000000";
      when 16#005A# => return "0000000100001000";
      when 16#005C# => return "0000000010000000";
      when 16#005E# => return "0000000100001000";
      when 16#0062# => return "0000100100001000";
      when 16#0064# => return "1111111111111111";
      when 16#0066# => return "0000100100001000";
      when 16#0068# => return "1111111111111110";
      when 16#006A# => return "0100000100111000";
      when 16#006C# => return "1000000000000000";
      when 16#006E# => return "0001000001111000";
      when 16#0070# => return "0100000110111000";
      when 16#0072# => return "0000000000000001";
      when 16#0074# => return "0000001000001101";
      when 16#0076# => return "0000000001100010";
      when 16#0078# => return "0000000000011000";
      when 16#007A# => return "0100000100111000";
      when 16#007C# => return "0000000000000001";
      when 16#007E# => return "0000001000001000";
      when 16#0080# => return "0000000001011110";
      when 16#0504# => return "0000001000001000";
      when 16#0506# => return "0000010100000000";
      when others   => return "0000000000000000";
    end case;
  end function;

end package body;
