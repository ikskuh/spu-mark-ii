LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY SPU_Mark_II IS

	PORT (
		rst             : in  std_logic; -- asynchronous reset
	  clk             : in  std_logic; -- system clock
		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_address     : out std_logic_vector(15 downto 0);
		write_operation : out std_logic; -- when '1' then bus write is requested, otherwise a read.
		byte_lan_select : out std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		mem_request     : out std_logic; -- when set to '1', the bus operation is requested
		mem_acknowledge : in  std_logic  -- when set to '1', the bus operation is acknowledged
	);
	
END ENTITY SPU_Mark_II;

ARCHITECTURE rtl OF SPU_Mark_II IS
	TYPE FSM_State IS (
		RESET, 
		FETCH_INSTR, 
		FETCH_IMM0, 
		PEEK_INP0, 
		POP_INP0, 
		FETCH_IMM1, 
		PEEK_INP1, 
		POP_INP1,
		
		READ_MEM,
		WRITE_MEM,

		PUSH_RESULT,
		
		EXEC_COPY,
		EXEC_IPGET,
		EXEC_GET,
		EXEC_SET,
		EXEC_STORE8,
		EXEC_STORE16,
		EXEC_LOAD8,
		EXEC_LOAD16,
		EXEC_FRSET,
		EXEC_FRGET,
		EXEC_BPGET,
		EXEC_BPSET,
		EXEC_SPGET,
		EXEC_SPSET,
		EXEC_ADD,
		EXEC_SUB,
		EXEC_MUL,
		EXEC_DIV,
		EXEC_MOD,
		EXEC_AND,
		EXEC_OR,
		EXEC_XOR,
		EXEC_NOT,
		EXEC_NEG,
		EXEC_ROL,
		EXEC_ROR,
		EXEC_BSWAP,
		EXEC_ASR,
		EXEC_LSL,
		EXEC_LSR
	);

	SUBTYPE CPU_WORD IS std_logic_vector(15 downto 0);
	
	CONSTANT NUL : CPU_WORD := "0000000000000000";
	CONSTANT INP_ZERO : std_logic_vector(1 downto 0) := "00";
	CONSTANT INP_IMM  : std_logic_vector(1 downto 0) := "01";
	CONSTANT INP_PEEK : std_logic_vector(1 downto 0) := "10";
	CONSTANT INP_POP  : std_logic_vector(1 downto 0) := "11";

	SIGNAL state, state_after_memory : FSM_State;
	
	SIGNAL REG_SP : CPU_WORD; -- stack pointer
	SIGNAL REG_BP : CPU_WORD; -- base pointer
	SIGNAL REG_IP : CPU_WORD; -- instruction pointer
	SIGNAL REG_FR : CPU_WORD; -- flag register
	
	SIGNAL REG_INSTR : CPU_WORD; -- current instruction word
	SIGNAL REG_I0    : CPU_WORD; -- input0
	SIGNAL REG_I1    : CPU_WORD; -- input1
	SIGNAL REG_OUT   : CPU_WORD; -- output
	
	ALIAS INSTR_EXEC : std_logic_vector(2 downto 0) is REG_INSTR(2 downto 0);
	ALIAS INSTR_IN0  : std_logic_vector(1 downto 0) is REG_INSTR(3 downto 2);
	ALIAS INSTR_IN1  : std_logic_vector(1 downto 0) is REG_INSTR(4 downto 3);
	ALIAS INSTR_FLAG : std_logic                    is REG_INSTR(5);
	ALIAS INSTR_OUT  : std_logic_vector(1 downto 0) is REG_INSTR(7 downto 6);
	ALIAS INSTR_CMD  : std_logic_vector(4 downto 0) is REG_INSTR(14 downto 10);
	
	ALIAS FLAG_Z : std_logic is REG_FR(0);
	ALIAS FLAG_N : std_logic is REG_FR(0);
	ALIAS FLAG_I : std_logic_vector(3 downto 0) is REG_FR(5 downto 2);
	
	function isInstructionExecuted(condition : std_logic_vector(2 downto 0); Z : std_logic; N : std_logic) return Boolean IS
	BEGIN
		case condition & Z & N is
			-- always
			when "000" & "00" => return true;
			when "000" & "01" => return true;
			when "000" & "10" => return true;
			when "000" & "11" => return true;
			
			-- is zero
			when "001" & "00" => return false;
			when "001" & "01" => return false;
			when "001" & "10" => return true;
			when "001" & "11" => return true;
			
			-- is not zero
			when "010" & "00" => return true;
			when "010" & "01" => return true;
			when "010" & "10" => return false;
			when "010" & "11" => return false;
			
			-- is greater zero
			when "011" & "00" => return true;
			when "011" & "01" => return false;
			when "011" & "10" => return false;
			when "011" & "11" => return false;
			
			-- is less than zero
			when "100" & "00" => return false;
			when "100" & "01" => return true;
			when "100" & "10" => return false;
			when "100" & "11" => return false;
			
			-- is greater or equal zero
			when "101" & "00" => return true;
			when "101" & "01" => return false;
			when "101" & "10" => return true;
			when "101" & "11" => return true;
			
			-- is less or equal zero
			when "110" & "00" => return false;
			when "110" & "01" => return true;
			when "110" & "10" => return true;
			when "110" & "11" => return true;
			
			when others => return false;
		end case;
	
	END;
	
	function getInstructionStartState (cmd : in std_logic_vector(4 downto 0)) return FSM_State IS
  begin
		case cmd is
			when "00000" => return EXEC_COPY; -- copy
			when "00001" => return EXEC_COPY; -- ipget
			when "00010" => return EXEC_COPY; -- get 
			when "00011" => return EXEC_COPY; -- set
			when "00100" => return EXEC_COPY; -- store8
			when "00101" => return EXEC_COPY; -- store16
			when "00110" => return EXEC_COPY; -- load8
			when "00111" => return EXEC_COPY; -- load16
			when "01000" => return RESET;           -- RESERVED
			when "01001" => return RESET;           -- RESERVED
			when "01010" => return EXEC_COPY; -- frget
			when "01011" => return EXEC_COPY; -- frset
			when "01100" => return EXEC_COPY; -- bpget
			when "01101" => return EXEC_COPY; -- bpset
			when "01110" => return EXEC_COPY; -- spget
			when "01111" => return EXEC_COPY; -- spset
			when "10000" => return EXEC_ADD;        -- add
			when "10001" => return EXEC_SUB;        -- sub
			when "10010" => return EXEC_COPY; -- mul
			when "10011" => return EXEC_COPY; -- div
			when "10100" => return EXEC_COPY; -- mod
			when "10101" => return EXEC_COPY; -- and
			when "10110" => return EXEC_COPY; -- or
			when "10111" => return EXEC_COPY; -- xor
			when "11000" => return EXEC_COPY; -- not
			when "11001" => return EXEC_COPY; -- neg
			when "11010" => return EXEC_COPY; -- rol
			when "11011" => return EXEC_COPY; -- ror
			when "11100" => return EXEC_COPY; -- bswap
			when "11101" => return EXEC_COPY; -- asr
			when "11110" => return EXEC_COPY; -- lsl
			when "11111" => return EXEC_COPY; -- lsr
			when others  => return RESET;           -- undefined anyways
		end case;
  end;
 
BEGIN

	P0: PROCESS (clk, rst) is
		procedure beginReadMemory16(signal address : in CPU_WORD; stateAfter : FSM_State) is
		begin
			state_after_memory <= stateAfter;
			mem_request <= '1';
			byte_lan_select <= "11";
			write_operation <= '0';
			bus_address <= address(15 downto 0) & "0";
			state <= READ_MEM;
		end procedure;

		impure function endReadMemory return boolean is
		begin
			return mem_acknowledge = '1';
		end function;

		procedure finish_instruction(
			signal state : out FSM_State; 
			signal reg_ip: inout CPU_WORD;
			signal reg_out: out CPU_WORD;
			signal reg_sp: inout CPU_WORD;
			output : in CPU_WORD
		) is
		begin
			reg_out <= output;
			case INSTR_OUT is
				when "00" => -- discard
					state <= FETCH_INSTR;
				when "01" => -- push
					state <= PUSH_RESULT;
					REG_SP <= std_logic_vector(unsigned(REG_SP) - to_unsigned(2, REG_IP'length));
					
				when "10" => -- jmp
					REG_IP <= output;
					state <= FETCH_INSTR;
				when "11" => -- jmp rel
					REG_IP <= std_logic_vector(unsigned(REG_IP) + unsigned(output(14 downto 0) & "0"));
					state <= FETCH_INSTR;
				when others =>
					state <= RESET;
			end case;		
		end procedure;

	BEGIN
	  if rst = '0' then
			state <= RESET;
		else
			if rising_edge(clk) then
				CASE state IS
					WHEN RESET =>
						REG_FR <= NUL;
						REG_BP <= NUL;
						REG_SP <= NUL;
						REG_IP <= NUL;
						beginReadMemory16(NUL, FETCH_INSTR);
					
					WHEN FETCH_INSTR => -- use with readMem16!
						variable result := endReadMemory();

						if memTransactionDone(result) then
							REG_INSTR <= memGetValue(result);
							
							if isInstructionExecuted(bus_data_in(2 downto 0), FLAG_Z, FLAG_N) then
							
								REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								
								-- start decoding instruction
								if INSTR_IN0 = INP_IMM then
									state <= FETCH_IMM0;
								elsif INSTR_IN0 = INP_POP then
									state <= POP_INP0;
								elsif INSTR_IN0 = INP_PEEK then
									state <= PEEK_INP0;
								elsif INSTR_IN1 = INP_IMM then
									REG_I0 <= NUL;
									state <= FETCH_IMM1;
								elsif INSTR_IN1 = INP_POP then
									REG_I0 <= NUL;
									state <= POP_INP1;
								elsif INSTR_IN1 = INP_PEEK then
									REG_I0 <= NUL;
									state <= PEEK_INP1;
								else
									REG_I0 <= NUL;
									REG_I1 <= NUL;
									state <= getInstructionStartState(INSTR_CMD);
								end if;
							else
								-- Instruction is not executed, go to next instruction
								if bus_data_in(4 downto 3) = "01" and bus_data_in(6 downto 5) = "01" then
									-- skip over both immediate values
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(6, REG_IP'length));
								elsif bus_data_in(4 downto 3) = "01" or bus_data_in(6 downto 5) = "01" then
									-- skip over one immediate value
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(4, REG_IP'length));
								else
									-- just skip the current instruction
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								end if;
								
								state <= FETCH_INSTR;
							end if;
							
						end if;
					
					WHEN FETCH_IMM0 => -- use with memRead16
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_IP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I0 <= bus_data_in;
							REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
							
							if INSTR_IN1 = INP_IMM then
								state <= FETCH_IMM1;
							elsif INSTR_IN1 = INP_POP then
								state <= POP_INP1;
							elsif INSTR_IN1 = INP_PEEK then
								state <= PEEK_INP1;
							else
								REG_I1 <= NUL;
								state <= getInstructionStartState(INSTR_CMD);
							end if;
						end if;
					
					WHEN PEEK_INP0 => -- use with peekMem
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_SP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I0 <= bus_data_in;
							
							if INSTR_IN1 = INP_IMM then
								state <= FETCH_IMM1;
							elsif INSTR_IN1 = INP_POP then
								state <= POP_INP1;
							elsif INSTR_IN1 = INP_PEEK then
								state <= PEEK_INP1;
							else
								REG_I1 <= NUL;
								state <= getInstructionStartState(INSTR_CMD);
							end if;
						end if;
					
					WHEN POP_INP0 => -- use with popMem
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_SP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I0 <= bus_data_in;
							REG_SP <= std_logic_vector(unsigned(REG_SP) + to_unsigned(2, REG_IP'length));
							
							if INSTR_IN1 = INP_IMM then
								state <= FETCH_IMM1;
							elsif INSTR_IN1 = INP_POP then
								state <= POP_INP1;
							elsif INSTR_IN1 = INP_PEEK then
								state <= PEEK_INP1;
							else
								REG_I1 <= NUL;
								state <= getInstructionStartState(INSTR_CMD);
							end if;
						end if;
						
					WHEN FETCH_IMM1 => -- use with memRead16
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_IP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I1 <= bus_data_in;
							REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
							
							state <= getInstructionStartState(INSTR_CMD);
						end if;
						
					WHEN PEEK_INP1 => -- use with peekMem
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_SP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I1 <= bus_data_in;
							state <= getInstructionStartState(INSTR_CMD);
						end if;
						
					WHEN POP_INP1 =>  -- use with popMem
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '0';
						bus_address <= REG_SP;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							REG_I1 <= bus_data_in;
							REG_SP <= std_logic_vector(unsigned(REG_SP) + to_unsigned(2, REG_IP'length));
							
							state <= getInstructionStartState(INSTR_CMD);
						end if;
					
					WHEN EXEC_COPY =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0);
					
					when EXEC_IPGET =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, std_logic_vector(unsigned(REG_IP) + unsigned(REG_I0(14 downto 1) & "0")));
						
					when EXEC_GET =>
						state <= RESET; -- not implemented yet

					when EXEC_SET =>
						state <= RESET; -- not implemented yet
					
					when EXEC_STORE8 =>
						state <= RESET; -- not implemented yet

					when EXEC_STORE16 =>
						state <= RESET; -- not implemented yet

					when EXEC_LOAD8 =>
						state <= RESET; -- not implemented yet

					when EXEC_LOAD16 =>
						state <= RESET; -- not implemented yet

					when EXEC_FRSET =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_FR and (not REG_I0));

					when EXEC_FRGET => 
						REG_FR <= (REG_I0 and (not REG_I1)) or (REG_FR and (REG_I1));
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_FR);

					when EXEC_BPGET =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_BP);
						
					when EXEC_BPSET =>
						REG_BP <= REG_I0;
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0);

					when EXEC_SPGET =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_SP);

					when EXEC_SPSET =>
						REG_SP <= REG_I0;
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0);

					WHEN EXEC_ADD =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, std_logic_vector(unsigned(REG_I0) + unsigned(REG_I1)));
						
					WHEN EXEC_SUB =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, std_logic_vector(unsigned(REG_I0) - unsigned(REG_I1)));
					
					when EXEC_MUL =>
						state <= RESET; -- not implemented yet

					when EXEC_DIV =>
						state <= RESET; -- not implemented yet
						
					when EXEC_MOD =>
						state <= RESET; -- not implemented yet
					
					when EXEC_AND =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0 and REG_I1);
					
					when EXEC_OR =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0 or REG_I1);

					when EXEC_XOR =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0 xor REG_I1);

					when EXEC_NOT =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, not REG_I0);

					when EXEC_NEG =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, std_logic_vector(-signed(REG_I0)));

					when EXEC_ROL =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0(14 downto 0) & REG_I0(15));
					
					when EXEC_ROR =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0(0) & REG_I0(15 downto 1));

					when EXEC_BSWAP =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0(7 downto 0) & REG_I0(15 downto 8));

					when EXEC_ASR =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0(15) & REG_I0(15 downto 1));

					when EXEC_LSL =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, REG_I0(14 downto 0) & "0");

					when EXEC_LSR =>
						finish_instruction(state, reg_ip, reg_out, reg_sp, "0" & REG_I0(15 downto 1));

					WHEN PUSH_RESULT => -- use with pushMem
						mem_request <= '1';
						byte_lan_select <= "11";
						write_operation <= '1';
						bus_address <= REG_SP;
						bus_data_out <= REG_OUT;
						if mem_acknowledge = '1' then
							mem_request <= '0';
							state <= FETCH_INSTR;
						end if;
							
				END CASE;
			end if;
		end if;	
	END PROCESS P0;

END ARCHITECTURE rtl ;