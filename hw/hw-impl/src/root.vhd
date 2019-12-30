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
		uart0_txd : out std_logic;
		sram_addr : out std_logic_vector(18 downto 0);
		sram_data : inout std_logic_vector(7 downto 0);
		sram_we   : out std_logic;
		sram_oe   : out std_logic;
		sram_ce   : out std_logic
	);
	
END ENTITY root;

use work.rom.all;

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

	COMPONENT SPU_Mark_II
	PORT(
		rst             : IN std_logic;
		clk             : IN std_logic;
		bus_data_in     : IN std_logic_vector(15 downto 0);
		bus_acknowledge : IN std_logic;          
		bus_data_out    : OUT std_logic_vector(15 downto 0);
		bus_address     : OUT std_logic_vector(15 downto 1);
		bus_write       : OUT std_logic;
		bus_bls         : OUT std_logic_vector(1 downto 0);
		bus_request     : OUT std_logic
		);
	END COMPONENT;
	
	signal cnt : unsigned(7 downto 0);
	signal floating0 : std_logic;
	signal floating1 : std_logic;
	signal uart_send_char : unsigned(7 downto 0);
	signal uart_receive_done : std_logic;

	SIGNAL bus_data_out :  std_logic_vector(15 downto 0);
	SIGNAL bus_data_in :  std_logic_vector(15 downto 0);
	SIGNAL bus_address :  std_logic_vector(15 downto 1);
	SIGNAL bus_write :  std_logic;
	SIGNAL bus_bls :  std_logic_vector(1 downto 0);
	SIGNAL bus_request :  std_logic;
	SIGNAL bus_acknowledge :  std_logic;

	SIGNAL clkdiv : unsigned(31 downto 0) := to_unsigned(0, 32);
	SIGNAL cpuclk : std_logic := '0';
	
	signal counter : unsigned(7 downto 0) := to_unsigned(0, 8);

	TYPE SRAM_Mode_Type IS (OFF,READ,WRITE);

	SIGNAL sram_data_in : std_logic_vector(7 downto 0);
	SIGNAL sram_data_out : std_logic_vector(7 downto 0);
	SIGNAL sram_mode : SRAM_Mode_Type := off;
	
	signal next_is_sram : boolean := false;

BEGIN	
	sram_data_in <= sram_data;
	sram_data <= sram_data_out when sram_mode = write else "ZZZZZZZZ";
	
	sram_we <= '0' when sram_mode = write else '1';
	sram_oe <= '0' when sram_mode = read else '1';
	sram_ce <= '0' when sram_mode /= off else '1';

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

	uut: SPU_Mark_II PORT MAP(
		rst => extrst,
		clk => cpuclk,
		bus_data_out => bus_data_out,
		bus_data_in => bus_data_in,
		bus_address => bus_address,
		bus_write => bus_write,
		bus_bls => bus_bls,
		bus_request => bus_request,
		bus_acknowledge => bus_acknowledge
	);
	
	cpuclkdiv : PROCESS(extclk, extrst)
	begin
		if extrst = '0' then
			clkdiv <= to_unsigned(0, clkdiv'length);
		else
			if rising_edge(extclk) then
				if clkdiv = 0 then
					clkdiv <= to_unsigned(1_200_000 - 1, clkdiv'length);
					cpuclk <= not cpuclk;
				else
					clkdiv <= clkdiv - 1;
				end if;
			end if;
		end if;

	end process;

	fake_mem: PROCESS(cpuclk, extrst) is
	begin
		if extrst = '0' then
				leds <= "11111111"; 
				sram_addr <= "0000000000000000000";
				sram_mode <= off;
				next_is_sram <= false;
		else
			if rising_edge(cpuclk) then
				if bus_request = '1' then
					leds <= "0" & not bus_address(7 downto 1); -- display requested bus address

					if next_is_sram then
						-- SRAM operation

						if bus_write = '0' then
							bus_data_in <= "00000000" & sram_data_in;
						end if;

						sram_mode <= off;
						bus_acknowledge <= '1';
						next_is_sram <= false;

					else
						if bus_address(15) = '1' then
							-- SRAM operation
							sram_mode <= write when bus_write = '1' else read;
							sram_addr <= "0000" & bus_address(14 downto 1) & "0";
							if bus_write = '1' then
								sram_data_out <= bus_data_out(7 downto 0);
							end if;
							next_is_sram <= true;
	
						else
							bus_acknowledge <= '0';
							if bus_write = '1' then
								-- ignore writes
							else
								bus_data_in <= builtin_rom(bus_address);
							end if;
						end if;
					end if;
				else
					leds <= "11111111"; -- LEDs off
					bus_acknowledge <= '0';
					sram_mode <= off;
					next_is_sram <= false;
				end if;
			end if;
		end if;
	END process;

	-- copy_leds: PROCESS (extclk, extrst)
	-- BEGIN
	--   if extrst = '0' then
	-- 		clkdiv <= to_unsigned(0, clkdiv'length);
	-- 		cnt    <= to_unsigned(0, cnt'length);
	-- 	else
	-- 		if rising_edge(extclk) then
	-- 			leds <= not std_logic_vector(uart_send_char);
	-- 		end if;
	-- 	end if;
	-- END PROCESS copy_leds;
	
END ARCHITECTURE rtl ;