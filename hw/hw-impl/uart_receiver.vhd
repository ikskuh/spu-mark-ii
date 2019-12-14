LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_Receiver IS
	GENERIC (
		clkfreq  : natural; -- frequency of 'clk' in Hz
		baudrate : natural  -- basic symbol rate of the UART ("bit / sec")
	);
	PORT (
		rst  : in  std_logic; -- asynchronous reset
	  clk  : in  std_logic; -- the clock for the uart operation.
		rxd  : in  std_logic; -- uses logic levels, non-inverted
		bsy  : out std_logic; -- is '1' when receiving a byte and '0' when not.
		data : out unsigned(7 downto 0); -- the data to send. must be valid in the first clock cycle where send='1'
		recv : out std_logic   -- when '1', data transmission is complete. this bit is only set for 1 clk cycle
	);
	
END ENTITY UART_Receiver;

ARCHITECTURE rtl OF UART_Receiver IS
	TYPE FSM_State IS (IDLE, START, BIT0, BIT1, BIT2, BIT3, BIT4, BIT5, BIT6, BIT7, STOP );
	CONSTANT clk_limit : natural := (clkfreq / baudrate) - 1;

	SIGNAL clkdiv : unsigned(31 downto 0);
	SIGNAL state : FSM_State;
	SIGNAL data_buffer : unsigned(7 downto 0);
BEGIN

	P0: PROCESS (clk, rst)
	BEGIN
	  if rst = '0' then
			clkdiv <= to_unsigned(0, clkdiv'length);
			state <= IDLE;
			recv <= '0';
			bsy <= '0';
		else
			if rising_edge(clk) then
				if state = IDLE then						
					-- prepare for first bit reception
					clkdiv <= to_unsigned(clk_limit / 2, clkdiv'length);
					
					recv <= '0';
					
					if rxd = '0' then
						state <= START;
						bsy <= '1';
					else
						bsy <= '0';
					end if;
	

				else
					-- this path here is clocked with `baud` Hz instead of the base frequency
					if clkdiv = 0 then
						clkdiv <= to_unsigned(clk_limit, clkdiv'length);
						
						CASE state IS
							WHEN IDLE => 
							-- transfer individual bits
							WHEN START =>
								if rxd = '0' then
									-- start bit confirmed, let's go!
									state <= BIT0;
								else
									-- this was a glitch, not a start bit
									state <= IDLE;
								end if;
								
							WHEN BIT0  => data_buffer(0) <= rxd; state <= BIT1;
							WHEN BIT1  => data_buffer(1) <= rxd; state <= BIT2;
							WHEN BIT2  => data_buffer(2) <= rxd; state <= BIT3;
							WHEN BIT3  => data_buffer(3) <= rxd; state <= BIT4;
							WHEN BIT4  => data_buffer(4) <= rxd; state <= BIT5;
							WHEN BIT5  => data_buffer(5) <= rxd; state <= BIT6;
							WHEN BIT6  => data_buffer(6) <= rxd; state <= BIT7;
							WHEN BIT7  => data_buffer(7) <= rxd; state <= STOP;
							
							WHEN STOP  =>
								recv <= '1';
								data <= data_buffer;
								state <= IDLE;
						END CASE;
						
					else
						clkdiv <= clkdiv - 1;
					end if;
				end if;
			end if;
		end if;
	END PROCESS P0;

END ARCHITECTURE rtl ;