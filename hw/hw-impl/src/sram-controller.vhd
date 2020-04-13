LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY SRAM_Controller IS
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
END ENTITY SRAM_Controller;

ARCHITECTURE rtl OF SRAM_Controller IS

	TYPE SRAM_Mode_Type IS (OFF,READ,WRITE);
  
  TYPE SRAM_State_Type IS (Init, AccessLow, AccessHighDelay, AccessHigh, Done);

	SIGNAL sram_data_in : std_logic_vector(7 downto 0);
	SIGNAL sram_data_out : std_logic_vector(7 downto 0);
	SIGNAL sram_mode : SRAM_Mode_Type := off;
  SIGNAL state : SRAM_State_Type := Init;
  SIGNAL next_state : SRAM_State_Type := Init;
  SIGNAL delay : unsigned(3 downto 0);

  -- turbo-slow
  CONSTANT sram_delay : natural := 50;

begin

  sram_data_in <= sram_data;
  sram_data <= sram_data_out when sram_mode = write else "ZZZZZZZZ";

  sram_we <= '0' when sram_mode = write else '1';
  sram_oe <= '0' when sram_mode = read  else '1';
  sram_ce <= '0'; -- when sram_mode /= off  else '1';

  p0 : PROCESS(clk, rst) is
    procedure goTo(st : SRAM_State_Type; cycCount: natural) is
    begin
      state <= st;
      delay <= to_unsigned(cycCount, delay'length);
    end procedure;
  BEGIN
  if rst = '0' then
    bus_acknowledge <= '0';
    sram_mode <= off;
    state <= Init;
    sram_data_out <= (others => '0');
    delay <= to_unsigned(0, delay'length);
  else
    if rising_edge(clk) then
      if bus_request = '1' then
        if delay /= 0 then
          delay <= delay - 1;
        else
          case state is
            when Init =>
              if bus_write = '1' then
                sram_mode <= write;
              else
                sram_mode <= read;
              end if;
              if bus_bls(0) = '1' then
                goTo(AccessLow, sram_delay);
                sram_addr <= bus_address(18 downto 1) & "0";
                sram_data_out <= bus_data_in(7 downto 0);
                bus_data_out(15 downto 8) <= "00000000";
              else
                goTo(AccessHigh, sram_delay);
                sram_addr <= bus_address(18 downto 1) & "1";
                sram_data_out <= bus_data_in(15 downto 8);
                bus_data_out(7 downto 0) <= "00000000";
              end if;

            when AccessLow =>
              sram_mode <= off;
              bus_data_out(7 downto 0) <= sram_data_in;
              if bus_bls(1) = '1' then
                goTo(AccessHighDelay, sram_delay);
              else
                bus_acknowledge <= '1';
                goTo(state, 0); -- no delay required, we are finished anyways
              end if;

            when AccessHighDelay =>
              if bus_write = '1' then
                sram_mode <= write;
              else
                sram_mode <= read;
              end if;
              sram_data_out <= bus_data_in(15 downto 8);
              sram_addr <= bus_address(18 downto 1) & "1";
              goTo(AccessHigh, sram_delay);

            when AccessHigh =>
              bus_data_out(15 downto 8) <= sram_data_in;
              bus_acknowledge <= '1';
              goTo(Done, 0); -- no delay required, we are done
              sram_mode <= off;
            
            when Done =>
              bus_acknowledge <= '1';
          
          end case;
        end if;
      else
        sram_mode <= off;
        state <= Init;
        bus_acknowledge <= '0';
      end if;
    end if;
  end if;
  END PROCESS;

end architecture;