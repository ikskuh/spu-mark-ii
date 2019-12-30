LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- LIBRARY lattice;
-- USE lattice.components.all;
 
-- LIBRARY machxo;
-- USE machxo.all;

ENTITY root IS
	PORT (
		leds      : out std_logic_vector(7 downto 0);
		switches  : in  std_logic_vector(3 downto 0);
		extclk    : in  std_logic;
		extrst    : in  std_logic;
		uart0_rxd : in  std_logic;
		uart0_txd : out std_logic
	);
	
END ENTITY root;

ARCHITECTURE rtl OF root IS	
	COMPONENT UART_Sender IS
		GENERIC (
			clkfreq  : natural;
			baudrate : natural
		);
		PORT (
		  rst  : in  std_logic;
			clk  : in  std_logic;
			txd  : out std_logic;
			bsy  : out std_logic;
			data : in unsigned(7 downto 0);
			send : in std_logic
		);
		
	END COMPONENT UART_Sender;
	
	COMPONENT UART_Receiver IS
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
		
	END COMPONENT UART_Receiver;
	
	signal cnt : unsigned(7 downto 0);
	signal clkdiv : unsigned(31 downto 0);
	signal floating0 : std_logic;
	signal floating1 : std_logic;
	signal uart_send_char : unsigned(7 downto 0);
	signal uart_receive_done : std_logic;
BEGIN	
	UART_Sender0: UART_Sender
	GENERIC MAP(
		clkfreq => 12_000_000, 
		baudrate => 19200 -- this is a *exakt* counter :)
	)
	PORT MAP(
		rst => extrst,
		clk => extclk,
		txd => uart0_txd,
		send => uart_receive_done,
		data => uart_send_char,
		bsy => floating0
	);
	
	UART_Receiver0: UART_Receiver
	GENERIC MAP(
		clkfreq => 12_000_000,
		baudrate => 19200
	)
	PORT MAP(
		rst => extrst,
		clk => extclk,
		rxd => uart0_rxd,
		bsy => floating1,
		data => uart_send_char,
		recv => uart_receive_done
	);

	copy_leds: PROCESS (extclk, extrst)
	BEGIN
	  if extrst = '0' then
			clkdiv <= to_unsigned(0, clkdiv'length);
			cnt    <= to_unsigned(0, cnt'length);
		else
			if rising_edge(extclk) then
				leds <= not std_logic_vector(uart_send_char);
			end if;
		end if;
	END PROCESS copy_leds;
	
END ARCHITECTURE rtl ;