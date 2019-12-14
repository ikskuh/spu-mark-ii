LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_Sender IS
	GENERIC (
		clkfreq  : natural; -- frequency of 'clk' in Hz
		baudrate : natural  -- basic symbol rate of the UART ("bit / sec")
	);
	PORT (
		rst  : in  std_logic; -- asynchronous reset
	  clk  : in  std_logic; -- the clock for the uart operation.
		txd  : out std_logic; -- uses logic levels, non-inverted
		bsy  : out std_logic; -- is '1' when sending a byte and '0' when not.
		data : in unsigned(7 downto 0); -- the data to send. must be valid in the first clock cycle where send='1'
		send : in std_logic   -- when '1', data transmission is started.
	);
	
END ENTITY UART_Sender;

ARCHITECTURE rtl OF UART_Sender IS
	CONSTANT clk_limit : natural := (clkfreq / baudrate) - 1;

	CONSTANT STATE_IDLE  : unsigned(3 downto 0) := to_unsigned( 0, 4);
	CONSTANT STATE_START : unsigned(3 downto 0) := to_unsigned( 1, 4);
	CONSTANT STATE_BIT0  : unsigned(3 downto 0) := to_unsigned( 2, 4);
	CONSTANT STATE_BIT1  : unsigned(3 downto 0) := to_unsigned( 3, 4);
	CONSTANT STATE_BIT2  : unsigned(3 downto 0) := to_unsigned( 4, 4);
	CONSTANT STATE_BIT3  : unsigned(3 downto 0) := to_unsigned( 5, 4);
	CONSTANT STATE_BIT4  : unsigned(3 downto 0) := to_unsigned( 6, 4);
	CONSTANT STATE_BIT5  : unsigned(3 downto 0) := to_unsigned( 7, 4);
	CONSTANT STATE_BIT6  : unsigned(3 downto 0) := to_unsigned( 8, 4);
	CONSTANT STATE_BIT7  : unsigned(3 downto 0) := to_unsigned( 9, 4);
	CONSTANT STATE_STOP  : unsigned(3 downto 0) := to_unsigned(10, 4);
	CONSTANT STATE_DONE  : unsigned(3 downto 0) := to_unsigned(11, 4);

	SIGNAL clkdiv : unsigned(31 downto 0);
	SIGNAL state : unsigned(3 downto 0);
	SIGNAL data_buffer : unsigned(7 downto 0);
BEGIN

	P0: PROCESS (clk, rst)
	BEGIN
	  if rst = '0' then
			clkdiv <= to_unsigned(0, clkdiv'length);
			state <= to_unsigned(0, state'length);
			bsy <= '0';
		else
			if rising_edge(clk) then
				if state = STATE_IDLE then
					-- STATE_IDLE waits for `send` to be '1', then starts the transmission
						
					-- prepare for first bit transmission
					clkdiv <= to_unsigned(clk_limit, clkdiv'length);
					
					txd <= '1';
					if send = '1' then
						data_buffer <= data;
						state <= STATE_BIT0; -- next state that is reached after bit time
						txd <= '0'; -- send start bit here, clkdiv is already set up so we wait until it's done before the next state transition
						bsy <= '1';
					else
						bsy <= '0';
					end if;
				
				else
					-- this path here is clocked with `baud` Hz instead of the base frequency
					if clkdiv = 0 then
						clkdiv <= to_unsigned(clk_limit, clkdiv'length);
						
						CASE state IS
							-- transfer individual bits
							WHEN STATE_BIT0  => txd <= data_buffer(0); state <= STATE_BIT1;
							WHEN STATE_BIT1  => txd <= data_buffer(1); state <= STATE_BIT2;
							WHEN STATE_BIT2  => txd <= data_buffer(2); state <= STATE_BIT3;
							WHEN STATE_BIT3  => txd <= data_buffer(3); state <= STATE_BIT4;
							WHEN STATE_BIT4  => txd <= data_buffer(4); state <= STATE_BIT5;
							WHEN STATE_BIT5  => txd <= data_buffer(5); state <= STATE_BIT6;
							WHEN STATE_BIT6  => txd <= data_buffer(6); state <= STATE_BIT7;
							WHEN STATE_BIT7  => txd <= data_buffer(7); state <= STATE_STOP;
							
							-- send stop bit
							WHEN STATE_STOP  => txd <= '1';            state <= STATE_DONE; -- we have to wait until our STOP bit is completly transferred!
							
							-- includes STATE_DONE!
							WHEN OTHERS      =>                         state <= STATE_IDLE;
						END CASE;
						
					else
						clkdiv <= clkdiv - 1;
					end if;
				end if;
			end if;
		end if;
	END PROCESS P0;

END ARCHITECTURE rtl ;


--<GyrosGeier> es gibt richtige enum-Typen
--<xq> ah!
--<xq> oh :D
--<GyrosGeier> die sind kuerzer zu verwenden, und haben keine Repraesentation
--<GyrosGeier> => der Compiler waehlt die bestmoegliche
--<GyrosGeier> und dann kann der WHEN OTHERS auch weg
--<xq> oki, genau aus dem grund hab ich gefragt :D
--<GyrosGeier> ich wuerde auch den clock-divider in einen eigenen Prozess packen, einfach der Lesbarkeit wegen
--<xq> okay? wie kommunizier ich dann damit?
--<GyrosGeier> ueber ein signal
--<GyrosGeier> also, Dein uart-Prozess ist dann halt sensitiv auf rst,bitclk
--<xq> ah und der "sendeprozess" legt erst los, wenn ich die startcondition gesetzt habe 
--<xq> und der andere prozess wartet dann darauf, dass der andere prozess das signal zurücksetzt?
--<GyrosGeier> ich wuerde die bitclk nur generieren, wenn bsy gesetzt ist
--<xq> hmm
--<GyrosGeier> => der sendeprozess gibt das Startbit raus und setzt bsy, dann laeuft die Uhr los
--<xq> ich grübel mal drüber nach
--<xq> ich hatte bisher das meiste immer in einem prozess :D
--<GyrosGeier> also gut, ich wuerde das eh alles komplett ohne Prozess machen
--<xq> inwiefern?
--<GyrosGeier> lauter direkte Signalzuweisungen auf architecture-Ebene
--<GyrosGeier> also concurrent assignment
--<GyrosGeier> das generiert idR deutlich besseren Code
--<xq> hm, dafür bin ich definitiv nicht fit genug :D
--<GyrosGeier> weil jeder Ast in einem Prozess, der nicht durchlaufen wird, erstmal ein Register generiert, um den alten Zustand zu halten
--<GyrosGeier> with state select txd <= '0' when start, data(0) when bit0, data(1) when bit1 ...
--<GyrosGeier> d.h. Dein txd-Bit is ein direkter Mux, der am aktuellen State haengt
--<GyrosGeier> und idle ist halt auch '1'
--<GyrosGeier> die Zuweisung zu state ist dann halt "ON bitclk"
--<xq> ah, das könnte ich mal probieren