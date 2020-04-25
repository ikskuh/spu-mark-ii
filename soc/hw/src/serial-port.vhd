LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Serial_Port IS
  GENERIC (
    clkfreq  : natural; -- frequency of 'clk' in Hz
    baudrate : natural  -- basic symbol rate of the UART ("bit / sec")
  );
	PORT (
		rst             : in  std_logic; -- asynchronous reset
    clk             : in  std_logic; -- system clock
    uart_txd        : out std_logic;
    uart_rxd        : in  std_logic;
		bus_data_out    : out std_logic_vector(15 downto 0);
    bus_data_in     : in  std_logic_vector(15 downto 0);
    -- UART has only a single address =>
    -- No address required
		-- bus_address     : in  std_logic_vector(15 downto 1);
		bus_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : in  std_logic; -- when set to '1', the bus operation is requested
		bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
	);
	
END ENTITY Serial_Port;

ARCHITECTURE rtl OF Serial_Port IS
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
      send : in std_logic;
      done : out std_logic
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

  COMPONENT FIFO IS
    GENERIC (
      width : natural := 16; -- width in bits
      depth : natural := 8  -- number of elements in the fifo
    );
    PORT (
      rst             : in  std_logic; -- asynchronous reset
      clk             : in  std_logic; -- system clock
      input           : in  std_logic_vector(width - 1 downto 0);
      output          : out std_logic_vector(width - 1 downto 0);
      insert          : in  std_logic;
      remove          : in  std_logic;
      empty           : out std_logic;
      full            : out std_logic;
      not_empty       : out std_logic
    );
  END COMPONENT FIFO;

  SIGNAL uart_rx_fifo_input     : std_logic_vector(7 downto 0);
  SIGNAL uart_rx_fifo_output    : std_logic_vector(7 downto 0);
  SIGNAL uart_rx_fifo_insert    : std_logic;
  SIGNAL uart_rx_fifo_remove    : std_logic;
  SIGNAL uart_rx_fifo_full      : std_logic;
  SIGNAL uart_rx_fifo_empty     : std_logic;
  SIGNAL uart_rx_fifo_not_empty : std_logic;

  SIGNAL uart_tx_fifo_input     : std_logic_vector(7 downto 0);
  SIGNAL uart_tx_fifo_output    : std_logic_vector(7 downto 0);
  SIGNAL uart_tx_fifo_insert    : std_logic;
  SIGNAL uart_tx_fifo_remove    : std_logic;
  SIGNAL uart_tx_fifo_full      : std_logic;
  SIGNAL uart_tx_fifo_empty     : std_logic;
  SIGNAL uart_tx_fifo_not_empty : std_logic;

  SIGNAL uart_tx_send           : std_logic;

  SIGNAL uart_tx_blocker        : std_logic;
  SIGNAL uart_tx_done           : std_logic;

begin
	uart_tx: UART_Sender
    GENERIC MAP(clkfreq => clkfreq,  baudrate => baudrate)
    PORT MAP(
      rst => rst,
      clk => clk,
      txd => uart_txd,
      send => uart_tx_send,
      data => unsigned(uart_tx_fifo_output),
      bsy => open,
      done => uart_tx_done
    )
  ;

  uart_tx_send <= uart_tx_fifo_remove;

  uart_tx_send_proc : process(clk,rst)
  begin
    if rst = '0' then
      uart_tx_fifo_remove <= '0';
      uart_tx_blocker <= '0';
    elsif rising_edge(clk) then
      if uart_tx_blocker = '1' then
        uart_tx_fifo_remove <= '0';
        if uart_tx_done = '1' then
          uart_tx_blocker <= '0';
        end if;
      else
        if uart_tx_fifo_not_empty = '1' then
          uart_tx_blocker <= '1';
          uart_tx_fifo_remove <= '1';
        end if;
      end if;

    end if;
    
  end process;

  tx_fifo: FIFO
    GENERIC MAP(width => 8, depth => 8) -- 8 elements a 8 bit
    PORT MAP (
      rst       => rst,
      clk       => clk,
      input     => uart_tx_fifo_input,
      output    => uart_tx_fifo_output,
      insert    => uart_tx_fifo_insert,
      remove    => uart_tx_fifo_remove,
      empty     => uart_tx_fifo_empty,
      full      => uart_tx_fifo_full,
      not_empty => uart_tx_fifo_not_empty
    )
  ;

  uart_rx: UART_Receiver
    GENERIC MAP(clkfreq => clkfreq,  baudrate => baudrate)
    PORT MAP(
      rst => rst,
      clk => clk,
      rxd => uart_rxd,
      bsy => open,
      std_logic_vector(data) => uart_rx_fifo_input,
      recv => uart_rx_fifo_insert
    )
  ;

  rx_fifo: FIFO
    GENERIC MAP(width => 8, depth => 8) -- 8 elements a 8 bit
    PORT MAP (
      rst       => rst,
      clk       => clk,
      input     => uart_rx_fifo_input,
      output    => uart_rx_fifo_output,
      insert    => uart_rx_fifo_insert,
      remove    => uart_rx_fifo_remove,
      empty     => uart_rx_fifo_empty,
      full      => uart_rx_fifo_full,
      not_empty => uart_rx_fifo_not_empty
    )
  ;

  fake_mem: PROCESS(clk, rst) is
	begin
    if rst = '0' then
      bus_acknowledge <= '0';
		else
			if rising_edge(clk) then
				if bus_request = '1' then
          if bus_write = '1' then
            if uart_tx_fifo_full = '0' and bus_bls(0) = '1' then
              if uart_tx_fifo_insert = '0' then
                report "Sending UART data: " & to_hstring(unsigned(bus_data_in(7 downto 0)));
              end if;
              uart_tx_fifo_input <= bus_data_in(7 downto 0);
              uart_tx_fifo_insert <= '1';
              bus_acknowledge <= '1';
            end if;
          else
            if uart_rx_fifo_empty = '0' then
              bus_acknowledge <= '1';
              uart_rx_fifo_remove <= '1';
              bus_data_out <= "00000000" & uart_rx_fifo_output;
            else
              bus_acknowledge <= '1';
              -- FIFO reading is non-blocking
              bus_data_out <= "1111111111111111";
            end if;
          end if;
				else
					uart_tx_fifo_insert <= '0';
					uart_rx_fifo_remove <= '0';
          bus_acknowledge <= '0';
				end if;
			end if;
		end if;
	END process;
  
end architecture;