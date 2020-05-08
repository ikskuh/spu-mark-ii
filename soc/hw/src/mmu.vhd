LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MMU IS
	PORT (
    clk           : in  std_logic;
    rst           : in  std_logic;

    -- CPU access to MMU interface
		cpu_data_out    : in  std_logic_vector(15 downto 0);
		cpu_data_in     : out std_logic_vector(15 downto 0);
		cpu_address     : in  std_logic_vector(15 downto 1);
		cpu_write       : in  std_logic; -- when '1' then bus write is requested, otherwise a read.
		cpu_bls         : in  std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		cpu_request     : in  std_logic; -- when set to '1', the bus operation is requested
    cpu_acknowledge : out std_logic; -- when set to '1', the bus operation is acknowledged
    
    -- bus output from MMU to system bus
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_address     : out std_logic_vector(23 downto 1);
		bus_write       : out std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : out std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : out std_logic; -- when set to '1', the bus operation is requested
    bus_acknowledge : in  std_logic; -- when set to '1', the bus operation is acknowledged
    
    -- System bus to mmu interface
		ctrl_data_out    : out std_logic_vector(15 downto 0);
		ctrl_data_in     : in  std_logic_vector(15 downto 0);
		ctrl_address     : in std_logic_vector(15 downto 1);
		ctrl_write       : in std_logic; -- when '1' then bus write is requested, otherwise a read.
		ctrl_bls         : in std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		ctrl_request     : in std_logic; -- when set to '1', the bus operation is requested
		ctrl_acknowledge : out  std_logic  -- when set to '1', the bus operation is acknowledged
	);
END ENTITY MMU;

ARCHITECTURE rtl OF MMU IS
  TYPE MEMBANK_T IS ARRAY(15 downto 0) OF std_logic_vector(15 downto 0);
  
  SIGNAL memory_bank : MEMBANK_T;

  -- SIGNAL memory_cfg : std_logic_vector(15 downto 0);

BEGIN

  p0: process(rst, clk)
    VARIABLE memory_cfg : std_logic_vector(15 downto 0);
  begin
    if rst = '0' then
			-- memory_bank is resetted in p1
    elsif rising_edge(clk) then
      bus_request  <= cpu_request;
      if cpu_request = '1' then
        -- store value for easier access
        memory_cfg := memory_bank(to_integer(unsigned(cpu_address(15 downto 12))));

        -- check if page is mapped and the access is valid
        if memory_cfg(0) = '1' and (cpu_write = '0' or memory_cfg(1) = '0') then
          
          if bus_request = '0' then
            report "translate CPU(" & to_hstring(cpu_address & "0") & ") to BUS(" & to_hstring(memory_cfg(15 downto 4) & cpu_address(11 downto 1) & "0") & ")";
          end if;

          -- translate address to physical memory
          bus_address     <= memory_cfg(15 downto 4) & cpu_address(11 downto 1);
          cpu_acknowledge <= bus_acknowledge;

          cpu_data_in     <= bus_data_in;
          bus_data_out    <= cpu_data_out;
          bus_write       <= cpu_write;
          bus_bls         <= cpu_bls;
        else
          -- TODO: trigger BUS error here
          bus_address     <= "00000000000000000000000";
          cpu_acknowledge <= '0';
          cpu_data_in     <= "0000000000000000";
          bus_data_out    <= "0000000000000000";
          bus_write       <= '0';
          bus_bls         <= "00";  
         end if;
      else    
        bus_address     <= "00000000000000000000000";
        cpu_acknowledge <= '0';
        cpu_data_in     <= "0000000000000000";
        bus_data_out    <= "0000000000000000";
        bus_write       <= '0';
        bus_bls         <= "00";   
      end if;
    end if;
  end process;

  mmu_cfg_access: process(clk, rst)
  begin
    if rst = '0' then
      for i in memory_bank'range loop
        -- create identitiy mapping, "0", "no caching", "no write protection", "page mapping enabled"
        memory_bank(i) <= "00000000" & std_logic_vector(to_unsigned(i,4)) & "0001";
      end loop;
    elsif rising_edge(clk) then
      if ctrl_request = '1' then
        if ctrl_bls = "11" then
          if ctrl_write = '1' then
            memory_bank(to_integer(unsigned(ctrl_address(4 downto 1)))) <= ctrl_data_in;
          else
            ctrl_data_out <= memory_bank(to_integer(unsigned(ctrl_address(4 downto 1))));
          end if;
        else 
          ctrl_data_out <= "1111111111111111";
        end if;
        ctrl_acknowledge <= '1';
      else
        ctrl_acknowledge <= '0';
      end if;
    end if;
  end process;

END ARCHITECTURE rtl ;