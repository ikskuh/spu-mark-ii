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
		bus_write       : out std_logic; -- when '1' then bus write is requested, otherwise a read.
		bus_bls         : out std_logic_vector(1 downto 0); -- selects the byte lanes for the memory operation
		bus_request     : out std_logic; -- when set to '1', the bus operation is requested
		bus_acknowledge : in  std_logic  -- when set to '1', the bus operation is acknowledged
	);
	
END ENTITY SPU_Mark_II;

ARCHITECTURE rtl OF SPU_Mark_II IS
	TYPE FSM_State IS (
		RESET, 
		FETCH_INSTR, 
		FETCH_INPUT0,
		FETCH_INPUT1,

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

	TYPE Mem_Operation IS (
		READ,
		WRITE,
		PUSH,
		PEEK,
		POP
	);

	SUBTYPE CPU_WORD IS std_logic_vector(15 downto 0);
	
	CONSTANT NUL : CPU_WORD := "0000000000000000";
	CONSTANT INP_ZERO : std_logic_vector(1 downto 0) := "00";
	CONSTANT INP_IMM  : std_logic_vector(1 downto 0) := "01";
	CONSTANT INP_PEEK : std_logic_vector(1 downto 0) := "10";
	CONSTANT INP_POP  : std_logic_vector(1 downto 0) := "11";

	SIGNAL state, state_after_memory : FSM_State;
	
	SIGNAL memOper : Mem_Operation;

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


	SIGNAL mem_bls      : std_logic_vector(1 downto 0) := "00";
	SIGNAL mem_req      : std_logic := '0';
	SIGNAL mem_write    : std_logic := '0';
	SIGNAL mem_data_out : std_logic_vector(15 downto 0) := NUL;
	SIGNAL mem_address  : std_logic_vector(15 downto 0) := NUL;
	SIGNAL mem_data_in  : std_logic_vector(15 downto 0);
	SIGNAL mem_ack      : std_logic;
	
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

	bus_bls      <= mem_bls;
	bus_request  <= mem_req;
	bus_write    <= mem_write;
	bus_data_out <= mem_data_out;
	bus_address  <= mem_address;
	mem_data_in  <= bus_data_in;
	mem_ack      <= bus_acknowledge;

	P0: PROCESS (clk, rst) is
		-- starts to read a value from memory and will change to stateAfter.
		-- stateAfter must use endReadMemory to complete the transfer.
		procedure beginReadMemory16(address : in CPU_WORD; stateAfter : FSM_State) is
		begin
			mem_req     <= '1';
			mem_bls     <= "11";
			mem_write    <= '0';
			mem_address <= address(15 downto 0) & "0";
			-- state_after_memory <= stateAfter;
			state <= stateAfter;
		end procedure;

		-- starts to write a value to memory and will change to stateAfter.
		-- stateAfter must use endWriteMemory to complete the transfer.
		procedure beginWriteMemory16(address : in CPU_WORD; value : in CPU_WORD; stateAfter : FSM_State) is
			begin
				mem_req      <= '1';
				mem_bls      <= "11";
				mem_write    <= '1';
				mem_address  <= address(15 downto 0) & "0";
				mem_data_out <= value;
				-- state_after_memory <= stateAfter;
				state <= stateAfter;
			end procedure;

		-- starts to pop a value and will change to stateAfter.
		-- stateAfter must use endReadMemory to complete the transfer.
		procedure beginPeek(stateAfter : FSM_State) is
		begin
			beginReadMemory16(REG_SP, stateAfter);
		end procedure;

		-- starts to pop a value and will change to stateAfter.
		-- stateAfter must use endReadMemory to complete the transfer.
		procedure beginPop(stateAfter : FSM_State) is
		begin
			beginReadMemory16(REG_SP, stateAfter);
			REG_SP <= std_logic_vector(unsigned(REG_SP) - to_unsigned(2, REG_SP'length));
		end procedure;

		-- starts to push the value and will change to stateAfter.
		-- stateAfter must use endWriteMemory to complete the transfer.
		procedure beginPush(value : in CPU_WORD; stateAfter : FSM_State) is
		begin
			REG_SP <= std_logic_vector(unsigned(REG_SP) + to_unsigned(2, REG_SP'length));
			beginWriteMemory16(REG_SP, value, stateAfter);
		end procedure;

		type ReadMemoryResult is record
			transferComplete : boolean;
			data             : CPU_WORD;
		end record;

		-- Ends a memory transaction process.
		-- Returns result.transferComplete = true if the transaction is complete.
		-- Fixed-up result is contained in result.data (so upper-byte-reads will be returned in the lower byte as well).
		-- Must not be called anymore after it returned true and no other begin* function was called!
		impure function endReadMemory return ReadMemoryResult is
		begin
			if mem_ack = '1' then
				mem_req <= '0';
				case mem_bls is
					when "00"   => return (transferComplete => true, data => NUL);
					when "01"   => return (transferComplete => true, data => "00000000" & mem_data_in(7 downto 0));
					when "10"   => return (transferComplete => true, data => "00000000" & mem_data_in(15 downto 8));
					when "11"   => return (transferComplete => true, data => bus_data_in);
					when others => return (transferComplete => false, data => NUL);
				end case;
			else 
				return (transferComplete => false, data => NUL);
			end if;
		end function;

		-- Ends a memory transaction process.
		-- Returns true if the transaction is complete.
		-- Must not be called anymore after it returned true and no other begin* function was called!
		impure function endWriteMemory return boolean is 
		begin
			if mem_ack = '1' then
				mem_req <= '0';
				return true;
			else
				return false;
			end if;
		end function;

		-- completes execution of a instruction and handles
		-- post-command processing.
		procedure finish_instruction(output : in CPU_WORD) is
		begin
			case INSTR_OUT is
				when "00" => -- discard
					state <= FETCH_INSTR;
				
				when "01" => -- push
					beginPush(output, PUSH_RESULT);
					
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

		procedure beginFetchArg1 is
		begin
			if INSTR_IN1 = INP_IMM then
				beginReadMemory16(REG_IP, FETCH_INPUT1);
				REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
			elsif INSTR_IN1 = INP_POP then
				beginPop(FETCH_INPUT1);
			elsif INSTR_IN1 = INP_PEEK then
				beginPeek(FETCH_INPUT1);
			else
				REG_I1 <= NUL;
				state <= getInstructionStartState(INSTR_CMD);
			end if;
		end procedure;

		variable mem_result : ReadMemoryResult;

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
						mem_result := endReadMemory;
						if mem_result.transferComplete then
							REG_INSTR <= mem_result.data;
							
							if isInstructionExecuted(mem_result.data(2 downto 0), FLAG_Z, FLAG_N) then
							
								REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								
								-- start decoding instruction
								if INSTR_IN0 = INP_IMM then
									beginReadMemory16(REG_IP, FETCH_INPUT0);
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								elsif INSTR_IN0 = INP_POP then
									beginPop(FETCH_INPUT0);
								elsif INSTR_IN0 = INP_PEEK then
									beginPeek(FETCH_INPUT0);
								elsif INSTR_IN1 = INP_IMM then
									REG_I0 <= NUL;
									beginReadMemory16(REG_IP, FETCH_INPUT1);
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								elsif INSTR_IN1 = INP_POP then
									REG_I0 <= NUL;
									beginPop(FETCH_INPUT1);
								elsif INSTR_IN1 = INP_PEEK then
									REG_I0 <= NUL;
									beginPeek(FETCH_INPUT1);
								else
									REG_I0 <= NUL;
									REG_I1 <= NUL;
									state <= getInstructionStartState(INSTR_CMD);
								end if;
							else
								-- Instruction is not executed, go to next instruction
								if mem_result.data(4 downto 3) = "01" and mem_result.data(6 downto 5) = "01" then
									-- skip over both immediate values
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(6, REG_IP'length));
								elsif mem_result.data(4 downto 3) = "01" or mem_result.data(6 downto 5) = "01" then
									-- skip over one immediate value
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(4, REG_IP'length));
								else
									-- just skip the current instruction
									REG_IP <= std_logic_vector(unsigned(REG_IP) + to_unsigned(2, REG_IP'length));
								end if;
								
								state <= FETCH_INSTR;
							end if;
							
						end if;
					
					WHEN FETCH_INPUT0 => -- use with memRead16, popMem, peekMem
						mem_result := endReadMemory;
						if mem_result.transferComplete then
							REG_I0 <= mem_result.data;
							beginFetchArg1;
						end if;
						
					WHEN FETCH_INPUT1 => -- use with memRead16, popMem, peekMem
						mem_result := endReadMemory;
						if mem_result.transferComplete then
							REG_I1 <= mem_result.data;
							state <= getInstructionStartState(INSTR_CMD);
						end if;
						
					WHEN EXEC_COPY =>
						finish_instruction(REG_I0);
					
					when EXEC_IPGET =>
						finish_instruction(std_logic_vector(unsigned(REG_IP) + unsigned(REG_I0(14 downto 1) & "0")));
						
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
						finish_instruction(REG_FR and (not REG_I0));

					when EXEC_FRGET => 
						REG_FR <= (REG_I0 and (not REG_I1)) or (REG_FR and (REG_I1));
						finish_instruction(REG_FR);

					when EXEC_BPGET =>
						finish_instruction(REG_BP);
						
					when EXEC_BPSET =>
						REG_BP <= REG_I0;
						finish_instruction(REG_I0);

					when EXEC_SPGET =>
						finish_instruction(REG_SP);

					when EXEC_SPSET =>
						REG_SP <= REG_I0;
						finish_instruction(REG_I0);

					WHEN EXEC_ADD =>
						finish_instruction(std_logic_vector(unsigned(REG_I0) + unsigned(REG_I1)));
						
					WHEN EXEC_SUB =>
						finish_instruction(std_logic_vector(unsigned(REG_I0) - unsigned(REG_I1)));
					
					when EXEC_MUL =>
						state <= RESET; -- not implemented yet

					when EXEC_DIV =>
						state <= RESET; -- not implemented yet
						
					when EXEC_MOD =>
						state <= RESET; -- not implemented yet
					
					when EXEC_AND =>
						finish_instruction(REG_I0 and REG_I1);
					
					when EXEC_OR =>
						finish_instruction(REG_I0 or REG_I1);

					when EXEC_XOR =>
						finish_instruction(REG_I0 xor REG_I1);

					when EXEC_NOT =>
						finish_instruction(not REG_I0);

					when EXEC_NEG =>
						finish_instruction(std_logic_vector(-signed(REG_I0)));

					when EXEC_ROL =>
						finish_instruction(REG_I0(14 downto 0) & REG_I0(15));
					
					when EXEC_ROR =>
						finish_instruction(REG_I0(0) & REG_I0(15 downto 1));

					when EXEC_BSWAP =>
						finish_instruction(REG_I0(7 downto 0) & REG_I0(15 downto 8));

					when EXEC_ASR =>
						finish_instruction(REG_I0(15) & REG_I0(15 downto 1));

					when EXEC_LSL =>
						finish_instruction(REG_I0(14 downto 0) & "0");

					when EXEC_LSR =>
						finish_instruction("0" & REG_I0(15 downto 1));

					WHEN PUSH_RESULT => -- use with pushMem
						if endWriteMemory then
							state <= FETCH_INSTR;
						end if;
						
				END CASE;
			end if;
		end if;	
	END PROCESS P0;

END ARCHITECTURE rtl ;