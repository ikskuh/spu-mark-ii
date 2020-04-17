LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY SPU_Mark_II IS

	PORT (
		rst             : in  std_logic; -- asynchronous reset
	  clk             : in  std_logic; -- system clock
		bus_data_out    : out std_logic_vector(15 downto 0);
		bus_data_in     : in  std_logic_vector(15 downto 0);
		bus_address     : out std_logic_vector(15 downto 1);
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

		PUSH_OUTPUT,

		DO_MEMORY,
		
		EXEC_COPY,
		EXEC_IPGET,
		EXEC_GET,
		EXEC_SET,
		EXEC_STORE8,
		EXEC_STORE16,
		EXEC_STORE_PROCESSING,
		EXEC_LOAD8,
		EXEC_LOAD16,
		EXEC_LOAD_PROCESSING,
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

	SUBTYPE CPU_BITS IS std_logic_vector(15 downto 0);
	SUBTYPE CPU_WORD IS unsigned(15 downto 0);
	
	CONSTANT NUL : CPU_WORD := to_unsigned(0, 16);
	CONSTANT NUL_BITS : CPU_BITS := "0000000000000000";

	CONSTANT INP_ZERO : std_logic_vector(1 downto 0) := "00";
	CONSTANT INP_IMM  : std_logic_vector(1 downto 0) := "01";
	CONSTANT INP_PEEK : std_logic_vector(1 downto 0) := "10";
	CONSTANT INP_POP  : std_logic_vector(1 downto 0) := "11";

	SIGNAL state, state_after_memory : FSM_State;

	SIGNAL REG_SP : CPU_WORD; -- stack pointer
	SIGNAL REG_BP : CPU_WORD; -- base pointer
	SIGNAL REG_IP : CPU_WORD; -- instruction pointer
	SIGNAL REG_FR : CPU_BITS; -- flag register
	
	SIGNAL REG_INSTR : CPU_BITS; -- current instruction word
	SIGNAL REG_I0    : CPU_WORD; -- input0
	SIGNAL REG_I1    : CPU_WORD; -- input1
	
	ALIAS INSTR_EXEC : std_logic_vector(2 downto 0) is REG_INSTR(2 downto 0);
	ALIAS INSTR_IN0  : std_logic_vector(1 downto 0) is REG_INSTR(4 downto 3);
	ALIAS INSTR_IN1  : std_logic_vector(1 downto 0) is REG_INSTR(6 downto 5);
	ALIAS INSTR_FLAG : std_logic                    is REG_INSTR(7);
	ALIAS INSTR_OUT  : std_logic_vector(1 downto 0) is REG_INSTR(9 downto 8);
	ALIAS INSTR_CMD  : std_logic_vector(4 downto 0) is REG_INSTR(14 downto 10);
	
	ALIAS FLAG_Z : std_logic is REG_FR(0);
	ALIAS FLAG_N : std_logic is REG_FR(0);
	ALIAS FLAG_I : std_logic_vector(3 downto 0) is REG_FR(5 downto 2);


	SIGNAL mem_bls      : std_logic_vector(1 downto 0) := "00";
	SIGNAL mem_req      : std_logic := '0';
	SIGNAL mem_write    : std_logic := '0';
	SIGNAL mem_data_out : std_logic_vector(15 downto 0) := NUL_BITS;
	SIGNAL mem_data_in  : std_logic_vector(15 downto 0) := NUL_BITS;
	SIGNAL mem_address  : std_logic_vector(15 downto 1) := NUL_BITS(15 downto 1);
	SIGNAL mem_ack      : std_logic;
	
	function getInstructionStartState (cmd : in std_logic_vector(4 downto 0)) return FSM_State IS
  begin
		case cmd is
			when "00000" => return EXEC_COPY; -- copy
			when "00001" => return EXEC_IPGET; -- ipget
			when "00010" => return EXEC_GET; -- get 
			when "00011" => return EXEC_SET; -- set
			when "00100" => return EXEC_STORE8; -- store8
			when "00101" => return EXEC_STORE16; -- store16
			when "00110" => return EXEC_LOAD8; -- load8
			when "00111" => return EXEC_LOAD16; -- load16
			when "01000" => return RESET;           -- RESERVED
			when "01001" => return RESET;           -- RESERVED
			when "01010" => return EXEC_FRGET; -- frget
			when "01011" => return EXEC_FRSET; -- frset
			when "01100" => return EXEC_BPGET; -- bpget
			when "01101" => return EXEC_BPSET; -- bpset
			when "01110" => return EXEC_SPGET; -- spget
			when "01111" => return EXEC_SPSET; -- spset
			when "10000" => return EXEC_ADD;        -- add
			when "10001" => return EXEC_SUB;        -- sub
			when "10010" => return EXEC_MUL; -- mul
			when "10011" => return EXEC_DIV; -- div
			when "10100" => return EXEC_MOD; -- mod
			when "10101" => return EXEC_AND; -- and
			when "10110" => return EXEC_OR; -- or
			when "10111" => return EXEC_XOR; -- xor
			when "11000" => return EXEC_NOT; -- not
			when "11001" => return EXEC_NEG; -- neg
			when "11010" => return EXEC_ROL; -- rol
			when "11011" => return EXEC_ROR; -- ror
			when "11100" => return EXEC_BSWAP; -- bswap
			when "11101" => return EXEC_ASR; -- asr
			when "11110" => return EXEC_LSL; -- lsl
			when "11111" => return EXEC_LSR; -- lsr
			when others  => return RESET;           -- undefined anyways
		end case;
	end;

	function disassemble(instruction : in CPU_BITS) return String is

		function conditionName(cond : in std_logic_vector(2 downto 0)) return String is
		begin
			case cond is
				when "000" =>  return "    ";
				when "001" =>  return "== 0";
				when "010" =>  return "!= 0";
				when "011" =>  return " > 0";
				when "100" =>  return " < 0";
				when "101" =>  return ">= 0";
				when "110" =>  return "<= 0";
				when others => return "????";
			end case;
		end function;

		function inputName(inp : in std_logic_vector(1 downto 0)) return String is
		begin
			case inp is
				when "00" =>  return "ZERO";
				when "01" =>  return "IMM ";
				when "10" =>  return "PEEK";
				when "11" =>  return "POP ";
				when others => return "???";
			end case;
		end function;

		function outputName(inp : in std_logic_vector(1 downto 0)) return String is
		begin
			case inp is
				when "00" =>  return "DISCARD";
				when "01" =>  return "PUSH";
				when "10" =>  return "JUMP";
				when "11" =>  return "R-JMP";
				when others => return "???";
			end case;
		end function;

		function flagName(inp : in std_logic) return String is
			begin
				if inp = '1' then
					return "+FLAGS";
				else
					return "      ";
				end if;
			end function;

		function commandName (cmd : in std_logic_vector(4 downto 0)) return String IS
		begin
			case cmd is
				when "00000" => return "COPY   "; -- copy
				when "00001" => return "IPGET  "; -- ipget
				when "00010" => return "GET    "; -- get 
				when "00011" => return "SET    "; -- set
				when "00100" => return "STORE8 "; -- store8
				when "00101" => return "STORE16"; -- store16
				when "00110" => return "LOAD8  "; -- load8
				when "00111" => return "LOAD16 "; -- load16
				when "01000" => return "RESET  ";           -- RESERVED
				when "01001" => return "RESET  ";           -- RESERVED
				when "01010" => return "FRGET  "; -- frget
				when "01011" => return "FRSET  "; -- frset
				when "01100" => return "BPGET  "; -- bpget
				when "01101" => return "BPSET  "; -- bpset
				when "01110" => return "SPGET  "; -- spget
				when "01111" => return "SPSET  "; -- spset
				when "10000" => return "ADD    ";        -- add
				when "10001" => return "SUB    ";        -- sub
				when "10010" => return "MUL    "; -- mul
				when "10011" => return "DIV    "; -- div
				when "10100" => return "MOD    "; -- mod
				when "10101" => return "AND    "; -- and
				when "10110" => return "OR     "; -- or
				when "10111" => return "XOR    "; -- xor
				when "11000" => return "NOT    "; -- not
				when "11001" => return "NEG    "; -- neg
				when "11010" => return "ROL    "; -- rol
				when "11011" => return "ROR    "; -- ror
				when "11100" => return "BSWAP  "; -- bswap
				when "11101" => return "ASR    "; -- asr
				when "11110" => return "LSL    "; -- lsl
				when "11111" => return "LSR    "; -- lsr
				when others  => return "INVALID";           -- undefined anyways
			end case;
		end function;

	begin
		return to_hstring(unsigned(instruction))
		  & ": " & conditionName(instruction(2 downto 0))
			& " " & inputName(instruction(4 downto 3))
			& " " & inputName(instruction(6 downto 5))
			& " " & commandName(instruction(14 downto 10))
			& " -> " & outputName(instruction(9 downto 8))
			& flagName(instruction(7));
	end function;
 
BEGIN

	bus_bls      <= mem_bls;
	bus_request  <= mem_req;
	bus_write    <= mem_write;
	bus_data_out <= mem_data_out;
	bus_address  <= mem_address;
	mem_ack      <= bus_acknowledge;

	P0: PROCESS (clk, rst) is

		procedure beginMemInput(address : in CPU_WORD; bls : std_logic_vector(1 downto 0); stateAfter : FSM_State) is
		begin
			mem_req     <= '1';
			mem_bls     <= bls;
			mem_write   <= '0';
			mem_address <= std_logic_vector(address(15 downto 1));
			state_after_memory <= stateAfter;
			state <= DO_MEMORY;
		end procedure;

		procedure beginMemOutput(address : in CPU_WORD; bls : std_logic_vector(1 downto 0); value : CPU_WORD; stateAfter : FSM_STATE) is
		begin
			mem_req      <= '1';
			mem_bls      <= bls;
			mem_write    <= '1';
			mem_address  <= std_logic_vector(address(15 downto 1));
			mem_data_out <= std_logic_vector(value);
			state_after_memory <= stateAfter;
			state <= DO_MEMORY;
		end procedure;

		-- starts to read a value from memory and will change to stateAfter.
		-- stateAfter must use endReadMemory to complete the transfer.
		procedure beginReadMemory16(address : in CPU_WORD; stateAfter : FSM_State) is
		begin
			beginMemInput(address, "11", stateAfter);
		end procedure;

		procedure beginReadMemory8(address : in CPU_WORD; stateAfter : FSM_State) is
		begin
			if address(0) = '1' then
				beginMemInput(address, "10", stateAfter);
			else
				beginMemInput(address, "01", stateAfter);
			end if;
		end procedure;

		-- starts to write a value to memory and will change to stateAfter.
		-- stateAfter must use endWriteMemory to complete the transfer.
		procedure beginWriteMemory16(address : in CPU_WORD; value : in CPU_WORD; stateAfter : FSM_State) is
		begin
			beginMemOutput(address, "11", value, stateAfter);
		end procedure;

		procedure beginWriteMemory8(address : in CPU_WORD; value : in unsigned(7 downto 0); stateAfter : FSM_State) is
		begin
			if address(0) = '1' then
				beginMemOutput(address, "10", value & "00000000", stateAfter);
			else 
				beginMemOutput(address, "01", "00000000" & value, stateAfter);
			end if;
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
			REG_SP <= REG_SP + 2;
		end procedure;

		-- starts to push the value and will change to stateAfter.
		-- stateAfter must use endWriteMemory to complete the transfer.
		procedure beginPush(value : in CPU_WORD; stateAfter : FSM_State) is
		begin
			beginWriteMemory16(REG_SP - 2, value, stateAfter);
			REG_SP <= REG_SP - 2;
		end procedure;

		-- completes execution of a instruction and handles
		-- post-command processing.
		procedure finish_instruction(output : in CPU_WORD) is
			variable temp : cpu_word;
		begin
			report "finalize instruction: " & to_hstring(output);
			if INSTR_FLAG = '1' then
				if output(15 downto 15) = 1 then
					FLAG_N <= '1';
					report "modify flag N -> 1";
				else
					FLAG_N <= '0';
					report "modify flag N -> 0";
				end if;
				if output = 0 then
					FLAG_Z <= '1';
					report "modify flag Z -> 1";
				else
					FLAG_Z <= '0';
					report "modify flag Z -> 0";
				end if;
			end if;

			case INSTR_OUT is
				when "00" => -- discard
					beginReadMemory16(REG_IP, FETCH_INSTR);
				
				when "01" => -- push
					beginPush(output, PUSH_OUTPUT);
					
				when "10" => -- jmp
					REG_IP <= output;
					beginReadMemory16(output, FETCH_INSTR);
				
				when "11" => -- jmp rel
					temp := REG_IP + (output(14 downto 0) & "0");
					REG_IP <= temp;
					beginReadMemory16(temp, FETCH_INSTR);
				
				when others =>
					state <= RESET;
			end case;		
		end procedure;

		procedure beginFetchArg1 is
			variable temp : cpu_word;
		begin
			if INSTR_IN1 = INP_IMM then
				beginReadMemory16(REG_IP, FETCH_INPUT1);
				REG_IP <= REG_IP + 2;
			elsif INSTR_IN1 = INP_POP then
				beginPop(FETCH_INPUT1);
			elsif INSTR_IN1 = INP_PEEK then
				beginPeek(FETCH_INPUT1);
			else
				REG_I1 <= NUL;
				state <= getInstructionStartState(INSTR_CMD);
			end if;
		end procedure;


		impure function isInstructionExecuted(condition : std_logic_vector(2 downto 0)) return Boolean IS
		BEGIN
			case condition is
				-- always
				when "000" => return true;
				
				-- is zero
				when "001" => return FLAG_Z = '1';
				
				-- is not zero
				when "010" => return FLAG_Z = '0';
				
				-- is greater zero
				when "011" => return FLAG_Z = '0' and FLAG_N = '0';
				
				-- is less than zero
				when "100" => return FLAG_Z = '0' and FLAG_N = '1';
				
				-- is greater or equal zero
				when "101" => return FLAG_Z = '1' or FLAG_N = '0';
				
				-- is less or equal zero
				when "110" => return FLAG_Z = '1' or FLAG_N = '1';
				
				when others => return false;
			end case;

		END;

		variable temp : CPU_WORD;

	BEGIN
	  if rst = '0' then
			state <= RESET;
		else
			if rising_edge(clk) then
				CASE state IS
					WHEN RESET =>
						REG_FR <= NUL_BITS;
						REG_BP <= NUL;
						REG_SP <= NUL;
						REG_IP <= NUL;
						beginReadMemory16(NUL, FETCH_INSTR);

					WHEN DO_MEMORY =>
						if mem_ack = '1' then
							mem_req <= '0';
							if mem_write = '0' then
								case mem_bls is
									when "00"   => mem_data_in <= NUL_BITS;
									when "01"   => mem_data_in <= "00000000" & bus_data_in(7 downto 0);
									when "10"   => mem_data_in <= "00000000" & bus_data_in(15 downto 8);
									when "11"   => mem_data_in <= bus_data_in;
									when others => mem_data_in <= NUL_BITS;
								end case;
							end if;
							state <= state_after_memory;
						end if;
					
					WHEN FETCH_INSTR => -- use with readMem16!
						REG_INSTR <= mem_data_in;
						
						if isInstructionExecuted(mem_data_in(2 downto 0)) then
							
							report "Execute " & disassemble(mem_data_in);

							-- start decoding instruction
							if mem_data_in(4 downto 3) = INP_IMM then
								REG_IP <= REG_IP + 4;
								beginReadMemory16(REG_IP + 2, FETCH_INPUT0);

							elsif mem_data_in(4 downto 3) = INP_POP then
								REG_IP <= REG_IP + 2;
								beginPop(FETCH_INPUT0);

							elsif mem_data_in(4 downto 3) = INP_PEEK then
								REG_IP <= REG_IP + 2;
								beginPeek(FETCH_INPUT0);
							elsif INSTR_IN1 = INP_IMM then
								REG_I0 <= NUL;
								beginReadMemory16(REG_IP + 2, FETCH_INPUT1);
								REG_IP <= REG_IP + 4;
							elsif INSTR_IN1 = INP_POP then
								REG_I0 <= NUL;
								beginPop(FETCH_INPUT1);
								REG_IP <= REG_IP + 2;
							elsif INSTR_IN1 = INP_PEEK then
								REG_I0 <= NUL;
								beginPeek(FETCH_INPUT1);
								REG_IP <= REG_IP + 2;
							else
								REG_I0 <= NUL;
								REG_I1 <= NUL;
								state <= getInstructionStartState(mem_data_in(14 downto 10));
								REG_IP <= REG_IP + 2;
							end if;
						else
							
							report "Skip    " & disassemble(mem_data_in);

							-- Instruction is not executed, go to next instruction
							if mem_data_in(4 downto 3) = "01" and mem_data_in(6 downto 5) = "01" then
								-- skip over both immediate values
								temp := REG_IP + 6;
							elsif mem_data_in(4 downto 3) = "01" or mem_data_in(6 downto 5) = "01" then
								-- skip over one immediate value
								temp := REG_IP + 4;
							else
								-- just skip the current instruction
								temp := REG_IP + 2;
							end if;
							
							REG_IP <= temp;
							beginReadMemory16(temp, FETCH_INSTR);

						end if;
					
					WHEN FETCH_INPUT0 => -- use with memRead16, popMem, peekMem
						REG_I0 <= unsigned(mem_data_in);
						beginFetchArg1;
						
					WHEN FETCH_INPUT1 => -- use with memRead16, popMem, peekMem
						REG_I1 <= unsigned(mem_data_in);
						state <= getInstructionStartState(INSTR_CMD);
						
					WHEN PUSH_OUTPUT =>
						beginReadMemory16(REG_IP, FETCH_INSTR);

					WHEN EXEC_COPY =>
						finish_instruction(REG_I0);
					
					when EXEC_IPGET =>
						finish_instruction(unsigned(REG_IP) + unsigned(REG_I0(14 downto 1) & "0"));
						
					when EXEC_GET =>
						state <= RESET; -- not implemented yet

					when EXEC_SET =>
						state <= RESET; -- not implemented yet
					
					when EXEC_STORE8 =>
						beginWriteMemory8(REG_I0, REG_I1(7 downto 0), EXEC_STORE_PROCESSING);

					when EXEC_STORE16 =>
						beginWriteMemory16(REG_I0, REG_I1, EXEC_STORE_PROCESSING);

					when EXEC_STORE_PROCESSING =>
						finish_instruction(REG_I1);

					when EXEC_LOAD8 =>
						beginReadMemory8(REG_I0, EXEC_LOAD_PROCESSING);

					when EXEC_LOAD16 =>
						beginReadMemory16(REG_I0, EXEC_LOAD_PROCESSING);

					when EXEC_LOAD_PROCESSING =>
						finish_instruction(unsigned(mem_data_in));

					when EXEC_FRSET =>
						finish_instruction(unsigned(std_logic_vector(REG_FR) and (not std_logic_vector(REG_I0))));

					when EXEC_FRGET => 
						finish_instruction(unsigned(REG_FR));
						REG_FR <= (std_logic_vector(REG_I0) and (not std_logic_vector(REG_I1))) or (REG_FR and std_logic_vector(REG_I1));

					when EXEC_BPGET =>
						finish_instruction(REG_BP);
						
					when EXEC_BPSET =>
						finish_instruction(REG_BP);
						REG_BP <= REG_I0;

					when EXEC_SPGET =>
						finish_instruction(REG_SP);

					when EXEC_SPSET =>
						finish_instruction(REG_SP);
						REG_SP <= REG_I0;

					WHEN EXEC_ADD =>
						finish_instruction(REG_I0 + REG_I1);
						
					WHEN EXEC_SUB =>
						finish_instruction(REG_I0 - REG_I1);
					
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
						finish_instruction(unsigned(-signed(REG_I0)));

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
					
				END CASE;
			end if;
		end if;	
	END PROCESS P0;

END ARCHITECTURE rtl ;