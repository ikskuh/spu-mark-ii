-- System-On-A-Chip definition

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SOC IS
  PORT (
    leds          : out   std_logic_vector(7 downto 0);
    switches      : in    std_logic_vector(3 downto 0);
    extclk        : in    std_logic;
    extrst        : in    std_logic;
    uart0_rxd     : in    std_logic;
    uart0_txd     : out   std_logic;
    sram_addr     : out   std_logic_vector(18 downto 0);
    sram_data     : inout std_logic_vector(7 downto 0);
    sram_we       : out   std_logic;
    sram_oe       : out   std_logic;
    sram_ce       : out   std_logic;
    vga_r         : out std_logic_vector(1 downto 0);
    vga_g         : out std_logic_vector(1 downto 0);
    vga_b         : out std_logic_vector(1 downto 0);
    vga_hs        : out std_logic;
    vga_vs        : out std_logic;
    dbg_miso_data : in    std_logic;
    dbg_mosi_data : out   std_logic;
    logic_dbg     : out   std_logic_vector(7 downto 0)
  );
END ENTITY SOC;

use work.generated.all;

ARCHITECTURE rtl OF SOC IS

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

  COMPONENT Register_RAM IS
    GENERIC (
      address_width : natural := 8   -- number of address bits => 2**address_width => number of bytes
    );

    PORT (
      rst             : in  std_logic; -- asynchronous reset
      clk             : in  std_logic; -- system clock
      bus_data_out    : out std_logic_vector(15 downto 0);
      bus_data_in     : in  std_logic_vector(15 downto 0);
      bus_address     : in std_logic_vector(address_width-1 downto 1);
      bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
      bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
      bus_request     : in std_logic; -- when set to '1', the bus operation is requested
      bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
    );
  END COMPONENT Register_RAM;

  COMPONENT FastRAM IS
  PORT (
    rst             : in  std_logic; -- asynchronous reset
    clk             : in  std_logic; -- system clock
    bus_data_out    : out std_logic_vector(15 downto 0);
    bus_data_in     : in  std_logic_vector(15 downto 0);
    bus_address     : in std_logic_vector(15 downto 1);
    bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
    bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
    bus_request     : in std_logic; -- when set to '1', the bus operation is requested
    bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
  );
  END COMPONENT FastRAM;

  COMPONENT Serial_Port IS
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
      bus_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
      bus_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
      bus_request     : in  std_logic; -- when set to '1', the bus operation is requested
      bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
    );
  END COMPONENT Serial_Port;

  COMPONENT ROM IS
  PORT (
    rst             : in  std_logic; -- asynchronous reset
    clk             : in  std_logic; -- system clock
    bus_data_out    : out std_logic_vector(15 downto 0);
    bus_data_in     : in  std_logic_vector(15 downto 0);
    bus_address     : in std_logic_vector(15 downto 1);
    bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
    bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
    bus_request     : in std_logic; -- when set to '1', the bus operation is requested
    bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
  );
  END COMPONENT ROM;

  COMPONENT SRAM_Controller IS
  PORT (
    rst             : in  std_logic; -- asynchronous reset
    clk             : in  std_logic; -- system clock
    -- sram interface
    sram_addr       : out std_logic_vector(18 downto 0);
    sram_data       : inout std_logic_vector(7 downto 0);
    sram_we         : out std_logic;
    sram_oe         : out std_logic;
    sram_ce         : out std_logic;

    -- system bus
    bus_data_out    : out std_logic_vector(15 downto 0);
    bus_data_in     : in  std_logic_vector(15 downto 0);
    bus_address     : in std_logic_vector(18 downto 1);
    bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
    bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
    bus_request     : in std_logic; -- when set to '1', the bus operation is requested
    bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
  );
  END COMPONENT SRAM_Controller;

  COMPONENT DebugPortReceiver IS
    PORT (
      clk      : in  std_logic;
      rst      : in  std_logic;
      dbg_clk  : in  std_logic;
      dbg_data : in  std_logic;
      rcv_data : out std_logic_vector(7 downto 0);
      rcv      : out std_logic
    );
  END COMPONENT;

  COMPONENT DebugPortSender IS
  GENERIC (
    freq_clk     : natural;
    baud         : natural := 9600
  );
  PORT (
    clk      : in  std_logic;
    rst      : in  std_logic;
    dbg_clk  : out std_logic;
    dbg_data : out std_logic;
    txd_data : in std_logic_vector(7 downto 0);
    txd      : in std_logic;
    complete : out std_logic
  );
  END COMPONENT DebugPortSender;

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

	COMPONENT VGA_Driver IS
	PORT (
		clk           : in  std_logic;
		rst           : in  std_logic;
		vga_r         : out std_logic_vector(1 downto 0);
		vga_g         : out std_logic_vector(1 downto 0);
		vga_b         : out std_logic_vector(1 downto 0);
		vga_hs        : out std_logic;
		vga_vs        : out std_logic;

		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_address     : in std_logic_vector(15 downto 1);
		bus_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : in std_logic; -- when set to '1', the bus operation is requested
		bus_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
	);
  END COMPONENT VGA_Driver;
  
  COMPONENT MMU IS
  PORT (
    clk           : in  std_logic;
    rst           : in  std_logic;

    cpu_data_out    : in  std_logic_vector(15 downto 0);
    cpu_data_in     : out std_logic_vector(15 downto 0);
    cpu_address     : in  std_logic_vector(15 downto 1);
    cpu_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
    cpu_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
    cpu_request     : in  std_logic; -- when set to '1', the bus operation is requested
    cpu_acknowledge : out std_logic;  -- when set to '1', the bus operation is acknowledged
    
    bus_data_in     : in  std_logic_vector(15 downto 0);
    bus_data_out    : out std_logic_vector(15 downto 0);
    bus_address     : out std_logic_vector(23 downto 1);
    bus_write       : out std_logic; -- when '1' then bus write is requested, otherwise a read.
    bus_bls         : out std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
    bus_request     : out std_logic; -- when set to '1', the bus operation is requested
    bus_acknowledge : in  std_logic; -- when set to '1', the bus operation is acknowledged

		ctrl_data_out    : out std_logic_vector(15 downto 0);
		ctrl_data_in     : in  std_logic_vector(15 downto 0);
		ctrl_address     : in std_logic_vector(15 downto 1);
		ctrl_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
		ctrl_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		ctrl_request     : in std_logic; -- when set to '1', the bus operation is requested
		ctrl_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
  );
  END COMPONENT MMU;
  
  CONSTANT clkfreq : natural := 48_000_000;

  TYPE TDebugState IS (
      -- Standard State
      Idle,

      -- Actions
      WriteMem8_AddrLow,
      WriteMem8_AddrHigh,
      WriteMem8_Value,

      WriteMem16_AddrLow,
      WriteMem16_AddrHigh,
      WriteMem16_ValueLow,
      WriteMem16_ValueHigh,

      ReadMem8_AddrLow,
      ReadMem8_AddrHigh,
      ReadMem8_Value,

      ReadMem16_AddrLow,
      ReadMem16_AddrHigh,
      ReadMem16_ValueLow,
      ReadMem16_ValueHigh,

      -- Debug Port Access
      WriteDebugPort,
      ReadDebugPort,

      -- Memory Bus Access
      WriteBus,
      ReadBus
  );

  TYPE TBusmaster IS (
    None,
    Debug,
    Processor
  );

  SIGNAL rst, clk : std_logic;

  SIGNAL sync_rst : std_logic;

  SIGNAL led_state : std_logic_vector(7 downto 0);

  SIGNAL cpu_halted : boolean;

  -- Debug Interface

  SIGNAL dbg_state : TDebugState;
  SIGNAL dbg_state_continuation : TDebugState;
  SIGNAL dbg_data_in : std_logic_vector(7 downto 0);
  SIGNAL dbg_data_out : std_logic_vector(7 downto 0);
  SIGNAL dbg_txd : std_logic;
  SIGNAL dbg_txd_done : std_logic;
  SIGNAL dbg_rxd_done : std_logic;

  SIGNAL dbg_buf_addr : std_logic_vector(15 downto 0);
  SIGNAL dbg_buf_data : std_logic_vector(15 downto 0);

  -- Memory Bus

  SIGNAL busmaster : TBusmaster;

  SIGNAL bus_data_out :  std_logic_vector(15 downto 0);
  SIGNAL bus_data_in :  std_logic_vector(15 downto 0);
  SIGNAL bus_address :  std_logic_vector(23 downto 1);
  SIGNAL bus_write :  std_logic;
  SIGNAL bus_bls :  std_logic_vector(1 downto 0);
  SIGNAL bus_request :  std_logic;
  SIGNAL bus_acknowledge :  std_logic;

  -- Master I/Os
  SIGNAL cpu_data_out : std_logic_vector(15 downto 0);
  SIGNAL cpu_data_in  : std_logic_vector(15 downto 0);
  SIGNAL cpu_address : std_logic_vector(15 downto 1);
  SIGNAL cpu_write : std_logic;
  SIGNAL cpu_bls : std_logic_vector(1 downto 0);
  SIGNAL cpu_request : std_logic;
  SIGNAL cpu_acknowledge : std_logic;

  SIGNAL mmu_data_out : std_logic_vector(15 downto 0);
  SIGNAL mmu_address : std_logic_vector(23 downto 1);
  SIGNAL mmu_write : std_logic;
  SIGNAL mmu_bls : std_logic_vector(1 downto 0);
  SIGNAL mmu_request : std_logic;
  SIGNAL mmu_acknowledge : std_logic;

  SIGNAL dbg_mem_data_out : std_logic_vector(15 downto 0);
  SIGNAL dbg_mem_address : std_logic_vector(23 downto 1);
  SIGNAL dbg_mem_write : std_logic;
  SIGNAL dbg_mem_bls : std_logic_vector(1 downto 0);
  SIGNAL dbg_mem_request : std_logic;
  SIGNAL dbg_mem_acknowledge : std_logic;

  -- Slave I/Os
  
  SIGNAL ram0_select : std_logic;
  SIGNAL ram0_ack : std_logic;
  SIGNAL ram0_out : std_logic_vector(15 downto 0);
  
  SIGNAL ram1_select : std_logic;
  SIGNAL ram1_ack : std_logic;
  SIGNAL ram1_out : std_logic_vector(15 downto 0);

  SIGNAL uart0_select : std_logic;
  SIGNAL uart0_ack : std_logic;
  SIGNAL uart0_out : std_logic_vector(15 downto 0);

  SIGNAL rom0_select : std_logic;
  SIGNAL rom0_ack : std_logic;
  SIGNAL rom0_out : std_logic_vector(15 downto 0);

  SIGNAL vga_select : std_logic;
  SIGNAL vga_ack : std_logic;
  SIGNAL vga_out : std_logic_vector(15 downto 0);

  SIGNAL mmu_ctrl_select : std_logic;
  SIGNAL mmu_ctrl_ack : std_logic;
  SIGNAL mmu_ctrl_out : std_logic_vector(15 downto 0);

  SIGNAL rom_range_select : std_logic;

  SIGNAL sim_bus_address :  std_logic_vector(23 downto 0);

BEGIN	

  -- Entities

  dbg_rx: UART_Receiver
  GENERIC MAP(clkfreq => clkfreq,  baudrate => 19_200)
  PORT MAP(
    rst => rst,
    clk => clk,
    rxd => dbg_miso_data,
    bsy => open,
    std_logic_vector(data) => dbg_data_in,
    recv => dbg_rxd_done
  );

  dbg_tx: UART_Sender
    GENERIC MAP(clkfreq => clkfreq,  baudrate => 19_200)
    PORT MAP(
      rst => rst,
      clk => clk,
      txd => dbg_mosi_data,
      send => dbg_txd,
      data => unsigned(dbg_data_out),
      bsy => open,
      done => dbg_txd_done
    );
  
  -- Bus Masters

  cpu: SPU_Mark_II PORT MAP(
    rst => rst,
    clk => clk,
    bus_data_out    => cpu_data_out,
    bus_data_in     => cpu_data_in,
    bus_address     => cpu_address,
    bus_write       => cpu_write,
    bus_bls         => cpu_bls,
    bus_request     => cpu_request,
    bus_acknowledge => cpu_acknowledge
  );

  mmu_0: MMU PORT MAP (
    clk              => clk,
    rst              => rst,

    cpu_data_out     => cpu_data_out,
    cpu_data_in      => cpu_data_in,
    cpu_address      => cpu_address,
    cpu_write        => cpu_write,
    cpu_bls          => cpu_bls,
    cpu_request      => cpu_request,
    cpu_acknowledge  => cpu_acknowledge,
    
    bus_data_in      => bus_data_in,
    bus_data_out     => mmu_data_out,
    bus_address      => mmu_address,
    bus_write        => mmu_write,
    bus_bls          => mmu_bls,
    bus_request      => mmu_request,
    bus_acknowledge  => mmu_acknowledge,

    ctrl_data_out    => mmu_ctrl_out,
    ctrl_data_in     => bus_data_out,
    ctrl_address     => bus_address(15 downto 1),
    ctrl_write       => bus_write,
    ctrl_bls         => bus_bls,
    ctrl_request     => mmu_ctrl_select,
    ctrl_acknowledge => mmu_ctrl_ack
  );

  -- Bus Slaves

  ram0 : FastRAM
    -- GENERIC MAP(address_width => 5)
    PORT MAP (
      rst             => rst,
      clk             => clk,
      bus_data_out    => ram0_out,
      bus_data_in     => bus_data_out,
      bus_address     => bus_address(15 downto 1),
      bus_write       => bus_write,
      bus_bls         => bus_bls,
      bus_request     => ram0_select,
      bus_acknowledge => ram0_ack
    );

  uart0 : Serial_Port
    GENERIC MAP (clkfreq  => clkfreq, baudrate => 19200)
    PORT MAP (
      rst             => rst,
      clk             => clk,
      uart_txd        => uart0_txd,
      uart_rxd        => uart0_rxd,
      bus_data_out    => uart0_out,
      bus_data_in     => bus_data_out,
      bus_write       => bus_write,
      bus_bls         => bus_bls,
      bus_request     => uart0_select,
      bus_acknowledge => uart0_ack
    );
  
  rom0 : ROM
    PORT MAP (
      rst             => rst,
      clk             => clk,
      bus_data_out    => rom0_out,
      bus_data_in     => bus_data_out,
      bus_address     => bus_address(15 downto 1),
      bus_write       => bus_write,
      bus_bls         => bus_bls,
      bus_request     => rom0_select,
      bus_acknowledge => rom0_ack
    );

  ram1 : SRAM_Controller
    PORT MAP (
      rst             => rst,
      clk             => clk,
      sram_addr       => sram_addr,
      sram_data       => sram_data,
      sram_we         => sram_we,
      sram_oe         => sram_oe,
      sram_ce         => sram_ce,
      bus_data_out    => ram1_out,
      bus_data_in     => bus_data_out,
      bus_address     => bus_address(18 downto 1), 
      bus_write       => bus_write,
      bus_bls         => bus_bls,
      bus_request     => ram1_select,
      bus_acknowledge => ram1_ack
    );


  vga: VGA_Driver
		PORT MAP (
			clk            => clk,
      rst            => rst,
      --
			vga_r          => vga_r,
			vga_g          => vga_g,
			vga_b          => vga_b,
			vga_hs         => vga_hs,
      vga_vs         => vga_vs,
      -- 
      bus_data_out    => vga_out,
      bus_data_in     => bus_data_out,
      bus_address     => bus_address(15 downto 1), 
      bus_write       => bus_write,
      bus_bls         => bus_bls,
      bus_request     => vga_select,
      bus_acknowledge => vga_ack
		);
  

  -- General Combinatorics

  rst <= extrst and sync_rst;
  clk <= extclk;

  leds(7 downto 0) <= not led_state;

  logic_dbg(0) <= extclk;
  logic_dbg(1) <= extrst;
  logic_dbg(2) <= bus_write;
  logic_dbg(3) <= bus_acknowledge;
  logic_dbg(4) <= rom0_select;
  logic_dbg(5) <= uart0_select;
  logic_dbg(6) <= ram0_select;
  logic_dbg(7) <= ram1_select;

  -- Bus Combinatorics (Bus Slaves)

  rom_range_select <= bus_request when bus_address(23 downto 16) = "00000000" else '0'; -- 0x00****
  ram0_select      <= bus_request when bus_address(23 downto 16) = "00000001" else '0'; -- 0x01****
  ram1_select      <= bus_request when bus_address(23 downto 16) = "00000010" else '0'; -- 0x02****
  uart0_select     <= bus_request when bus_address(23 downto 16) = "10000000" else '0'; -- 0x80****
  vga_select       <= bus_request when bus_address(23 downto 16) = "10000001" else '0'; -- 0x81****

  rom0_select      <= bus_request when bus_address(15 downto 12) /= "1111" else '0'; -- 0x00****
  mmu_ctrl_select  <= bus_request when bus_address(15 downto 12)  = "1111" else '0'; -- 0x00F***

  bus_acknowledge <= rom0_ack     when rom0_select  = '1' else
                     uart0_ack    when uart0_select = '1' else
                     ram0_ack     when ram0_select  = '1' else
                     ram1_ack     when ram1_select  = '1' else
                     vga_ack      when vga_select   = '1' else
                     mmu_ctrl_ack when mmu_ctrl_select = '1' else
                     '0';

  bus_data_in  <= rom0_out     when rom0_select  = '1' else
                  uart0_out    when uart0_select = '1' else
                  ram0_out     when ram0_select  = '1' else
                  ram1_out     when ram1_select  = '1' else
                  vga_out      when vga_select   = '1' else
                  mmu_ctrl_out when mmu_ctrl_select = '1' else
                   "0000000000000000";

  -- Bus Combinatorics (Bus Masters)

  bus_address  <= mmu_address      when busmaster = Processor else
                  dbg_mem_address  when busmaster = Debug     else
                  "00000000000000000000000";

  sim_bus_address <= bus_address & "0";
  
  bus_data_out <= mmu_data_out     when busmaster = Processor else
                  dbg_mem_data_out when busmaster = Debug     else
                  "0000000000000000";

  bus_write    <= mmu_write        when busmaster = Processor else
                  dbg_mem_write    when busmaster = Debug     else
                  '0';

  bus_bls      <= mmu_bls          when busmaster = Processor else
                  dbg_mem_bls      when busmaster = Debug     else
                  "00";
                
  bus_request  <= mmu_request      when busmaster = Processor else
                  dbg_mem_request  when busmaster = Debug     else
                  '0'; 

  mmu_acknowledge     <= bus_acknowledge when busmaster = Processor else '0';
  dbg_mem_acknowledge <= bus_acknowledge when busmaster = Debug else '0';

  -- Processes

  busmgr: process(clk,rst)
  begin
    if rst = '0' then
      busmaster <= None;
    elsif rising_edge(clk) then
      if busmaster = None then
        -- Priority-encoded bus requests
        if dbg_mem_request = '1' then
          busmaster <= Debug;
        elsif mmu_request = '1' and not cpu_halted then
          busmaster <= Processor;
        end if;
      else
        -- Bus request is mapped above to the right bus master request
        if bus_request = '0' then
          busmaster <= None;
        end if;
      end if;
    end if;
  end process;

  dbg_proc: process(clk,extrst)

    procedure dbgWrite(stateAfter : TDebugState; value: std_logic_vector(7 downto 0)) is
    begin
      dbg_txd <= '1';
      dbg_data_out <= value;
      dbg_state <= WriteDebugPort;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure dbgSendChar(stateAfter : TDebugState; char: character) is
    begin
      dbgWrite(stateAfter, std_logic_vector(to_unsigned(character'pos(char), 8)));
    end procedure;

    procedure dbgRead(stateAfter : TDebugState) is
    begin
      dbg_state <= ReadDebugPort;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure busWrite8(stateAfter: TDebugState; address: std_logic_vector(15 downto 0); value: std_logic_vector(7 downto 0)) is
    begin
      dbg_mem_request <= '1';
      dbg_mem_write   <= '1';
      dbg_mem_address <= address(15 downto 1);

      if address(0) = '0' then
        dbg_mem_data_out <= "00000000" & value;
        dbg_mem_bls <= "01";
      else
        dbg_mem_data_out <= value & "00000000";
        dbg_mem_bls <= "10";
      end if;

      dbg_state <= WriteBus;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure busWrite16(stateAfter: TDebugState; address: std_logic_vector(15 downto 1); value: std_logic_vector(15 downto 0)) is
    begin
      dbg_mem_request <= '1';
      dbg_mem_write   <= '1';
      dbg_mem_address <= address;
      dbg_mem_data_out <= value;
      dbg_mem_bls <= "11";	
      dbg_state <= WriteBus;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure busRead16(stateAfter: TDebugState; address: std_logic_vector(15 downto 0)) is
    begin
      dbg_mem_request <= '1';
      dbg_mem_write   <= '0';
      dbg_mem_address <= address(15 downto 1);
      dbg_mem_bls     <= "11";

      dbg_state <= ReadBus;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure busRead8(stateAfter: TDebugState; address: std_logic_vector(15 downto 0)) is
    begin
      dbg_mem_request <= '1';
      dbg_mem_write   <= '0';
      dbg_mem_address <= address(15 downto 1);

      if address(0) = '0' then
        dbg_mem_bls <= "01";
      else
        dbg_mem_bls <= "10";
      end if;

      dbg_state <= ReadBus;
      dbg_state_continuation <= stateAfter;
    end procedure;

    procedure executeReset is
    begin
      dbg_state <= Idle;
      dbg_txd <= '0';
      dbg_mem_data_out <= "0000000000000000";
      dbg_mem_address  <= "00000000000000000000000";
      dbg_mem_write <= '0';
      dbg_mem_bls <= "00";
      dbg_mem_request <= '0';
      sync_rst <= '1';
      cpu_halted <= false;
      led_state <= "00000000";
    end procedure;

  BEGIN

    if extrst = '0' then
      executeReset;
    elsif rising_edge(clk) then
      if sync_rst = '0' then
        executeReset;
      end if;

      led_state(0) <= '1' when dbg_state /= Idle else '0';
      led_state(1) <= bus_request;
      led_state(2) <= bus_acknowledge;
      led_state(3) <= '1' when bus_bls = "11" else '0';
      led_state(7 downto 4) <= bus_address(4 downto 1);

      case dbg_state is
        when Idle =>
          if dbg_rxd_done = '1' then
            case character'val(to_integer(unsigned(dbg_data_in))) is
              when 'B' => -- 'B'yte write { AL, AH, V }
                dbgRead(WriteMem8_AddrLow);

              when 'b' => -- 'b'yte read { AL, AH }
                dbgRead(ReadMem8_AddrLow);

              when 'W' => -- 'W'ord write { AL, AH, VL, VH }
                dbgRead(WriteMem16_AddrLow);

              when 'w' => -- 'w'ord read { AL, AH }
                dbgRead(ReadMem16_AddrLow);

              when 'R' => -- 'R'eset system
                sync_rst <= '0';

              when 'H' => -- 'H'alt system
                cpu_halted <= true;
               
              when 'h' => -- un'h'alt system
                cpu_halted <= false;

              when others => -- 'E'rror
                dbgSendChar(Idle, 'E');

            end case;

          end if;

        -- 8 Bit Write Access

        when WriteMem8_AddrLow => 
          dbg_buf_addr(7 downto 0) <= dbg_data_in;
          dbgRead(WriteMem8_AddrHigh);

        when WriteMem8_AddrHigh => 
          dbg_buf_addr(15 downto 8) <= dbg_data_in;
          dbgRead(WriteMem8_Value);

        when WriteMem8_Value => 
          busWrite8(Idle, dbg_buf_addr, dbg_data_in);
        
        -- 16 Bit Write Access

        when WriteMem16_AddrLow => 
          dbg_buf_addr(7 downto 0) <= dbg_data_in;
          dbgRead(WriteMem16_AddrHigh);

        when WriteMem16_AddrHigh => 
          dbg_buf_addr(15 downto 8) <= dbg_data_in;
          dbgRead(WriteMem16_ValueLow);

        when WriteMem16_ValueLow => 
          dbg_buf_data(7 downto 0) <= dbg_data_in;
          dbgRead(WriteMem16_ValueHigh);

        when WriteMem16_ValueHigh => 
          busWrite16(Idle, dbg_buf_addr(15 downto 1), dbg_data_in & dbg_buf_data(7 downto 0));

        -- Read a 8 bit word from the bus

        when ReadMem8_AddrLow =>
          dbg_buf_addr(7 downto 0) <= dbg_data_in;
          dbgRead(ReadMem8_AddrHigh);

        when ReadMem8_AddrHigh =>
          dbg_buf_addr(15 downto 8) <= dbg_data_in;
          busRead8(ReadMem8_Value, dbg_buf_addr);

        when ReadMem8_Value =>
          dbgWrite(Idle, dbg_buf_data(7 downto 0));
         
        -- Read a 16 bit word from the bus

        when ReadMem16_AddrLow =>
          dbg_buf_addr(7 downto 0) <= dbg_data_in;
          dbgRead(ReadMem16_AddrHigh);

        when ReadMem16_AddrHigh =>
          dbg_buf_addr(15 downto 8) <= dbg_data_in;
          busRead16(ReadMem16_ValueLow, dbg_buf_addr);

        when ReadMem16_ValueLow =>
          dbgWrite(ReadMem16_ValueHigh, dbg_buf_data(7 downto 0));
        
        when ReadMem16_ValueHigh =>
          dbgWrite(Idle, dbg_buf_data(15 downto 8));


        -- Reads a word from the bus, then continues
        when ReadBus =>
          if dbg_mem_acknowledge = '1' then
            dbg_mem_request <= '0';

            if dbg_mem_bls = "11" then
              dbg_buf_data <= bus_data_in;
            elsif dbg_mem_bls = "10" then
              dbg_buf_data <= "00000000" & bus_data_in(15 downto 8);
            elsif dbg_mem_bls = "01" then
              dbg_buf_data <= "00000000" & bus_data_in(7 downto 0);
            end if;

            dbg_state <= dbg_state_continuation;
          end if;

        -- Writes a word to the bus, then continues
        when WriteBus =>
          if dbg_mem_acknowledge = '1' then
            dbg_mem_request <= '0';
            dbg_state <= dbg_state_continuation;
          end if;


        -- Waits until data is sent, then continues
        when WriteDebugPort =>
          dbg_txd <= '0'; -- we already signalled the start
          if dbg_txd_done = '1' then
            dbg_state <= dbg_state_continuation;
          end if;

        -- Waits until data is read, then continues
        when ReadDebugPort =>
          if dbg_rxd_done = '1' then
            dbg_state <= dbg_state_continuation;
          end if;

      end case;
    end if;
  end process;


END ARCHITECTURE rtl ;