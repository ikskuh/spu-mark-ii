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
	
	signal cnt : unsigned(7 downto 0);
	signal clkdiv : unsigned(31 downto 0);
	signal floating : std_logic;
	signal uart_send_char : unsigned(7 downto 0);
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
		send => '1',
		data => uart_send_char, -- 'X'
		bsy => floating
	);

	copy_leds: PROCESS (extclk, extrst)
	BEGIN
	  if extrst = '0' then
			clkdiv <= to_unsigned(0, clkdiv'length);
			cnt    <= to_unsigned(0, cnt'length);
		else
			if rising_edge(extclk) then
				uart_send_char <= to_unsigned(48, 8) + unsigned(switches);
				if clkdiv = 11_999_999 then
					clkdiv <= to_unsigned(0, clkdiv'length);
					cnt <= cnt + unsigned(switches);
					leds <= not std_logic_vector(cnt);
				else
					clkdiv <= clkdiv + 1;
				end if;
			end if;
		end if;
	END PROCESS copy_leds;
	
	-- uart0_txd <= uart0_rxd;
	
END ARCHITECTURE rtl ;