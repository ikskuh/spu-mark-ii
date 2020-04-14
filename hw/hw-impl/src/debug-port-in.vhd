-- Debug Port receiver

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY DebugPortReceiver IS
	PORT (
		clk      : in  std_logic;
		rst      : in  std_logic;
		dbg_clk  : in  std_logic;
    dbg_data : in  std_logic;
    rcv_data : out std_logic_vector(7 downto 0);
    rcv      : out std_logic
	);
END ENTITY DebugPortReceiver;

ARCHITECTURE rtl OF DebugPortReceiver IS
	SIGNAL pos : unsigned(3 downto 0);
	SIGNAL counter : unsigned(13 downto 0);
	SIGNAL input_buffer : std_logic_vector(6 downto 0);
	SIGNAL state : bit;
begin

	p0: process(rst, clk)
	begin
		if rst = '0' then
			state <= '0';
			pos <= to_unsigned(0, pos'length);
			counter <= to_unsigned(0, counter'length);
    elsif rising_edge(clk) then
      rcv <= '0';
			if state = '0' then
				if dbg_clk = '1' then
					if pos = 7 then
						counter <= to_unsigned(0, counter'length);
						pos <= to_unsigned(0, pos'length);
						rcv_data <= input_buffer(0)
                      & input_buffer(1)
                      & input_buffer(2)
                      & input_buffer(3)
                      & input_buffer(4)
                      & input_buffer(5)
                      & input_buffer(6)
                      & dbg_data;
            rcv <= '1';
					else
						input_buffer(to_integer(pos)) <= dbg_data;
						pos <= pos + 1;
					end if;
					state <= '1';
				else
					if counter = 11_999 then
						counter <= to_unsigned(0, counter'length);
						pos <= to_unsigned(0, pos'length);
					else
						counter <= counter + 1;
					end if;
				end if;
			else
				if dbg_clk = '0' then
					state <= '0';
				elsif counter /= 11_999 then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

end architecture;