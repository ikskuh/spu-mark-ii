LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY FIFO IS
  GENERIC (
    width : natural := 16; -- width in bits
    depth : natural := 8   -- number of elements in the fifo
  );

	PORT (
		rst             : in  std_logic; -- asynchronous reset
	  clk             : in  std_logic; -- system clock
    input           : in  std_logic_vector(width - 1 downto 0);
    output          : out std_logic_vector(width - 1 downto 0);
    insert          : in  std_logic;
    remove          : in  std_logic;
    empty           : out std_logic;
    not_empty       : out std_logic;
    full            : out std_logic
	);
	
END ENTITY FIFO;

ARCHITECTURE rtl OF FIFO IS

  SUBTYPE WORD_Type IS std_logic_vector(width - 1 downto 0);

  SUBTYPE INDEX_Type IS integer range 0 to depth - 1; 

  TYPE Storage_Type IS ARRAY (0 to depth - 1) OF WORD_Type;

  signal storage : Storage_Type;
  signal head : INDEX_Type := 0;
  signal tail : INDEX_Type := 0;

  signal inserting : boolean := false;
  signal removing : boolean := false;

  -- Increment and wrap
  function incr(index : in index_type) return index_type is
  begin
    if index = index_type'high then
      return index_type'low;
    else
      return index + 1;
    end if;
  end function;

begin 

  p0 : process(clk, rst) is
  begin
    if rst = '0' then

      empty <= '1';
      full <= '0';
      head <= 0;
      tail <= 0;
      inserting <= false;
      removing <= false;
    else
      if rising_edge(clk) then
        output <= storage(tail);
        empty <= '1' when head = tail else '0';
        full <= '1' when incr(head) = tail else '0';
        not_empty <= '1' when head /= tail else '0';

        if inserting then
          if insert = '0' then
            inserting <= false;
          end if;
        else
          if insert = '1' then
            storage(head) <= input;
            head <= incr(head);
            inserting <= true;
          end if;
        end if;

        if removing then
          if remove = '0' then
            removing <= false;
          end if;
        else
          if remove = '1' then
            if tail /= head then
              tail <= incr(tail);
            end if;
            removing <= true;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;