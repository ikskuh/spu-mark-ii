#include <cstdint>
#include <cassert>
#include <cstddef>
#include <cstring>
#include <array>

using byte = uint8_t;
using word = uint16_t;

template<typename T>
std::make_signed_t<T> to_signed(T w)
{
	std::make_signed_t<T> r;
	memcpy(&r, &w, sizeof(word));
	return r;
}

template<typename T>
std::make_unsigned_t<T> to_unsigned(T w)
{
	std::make_unsigned_t<T> r;
	memcpy(&r, &w, sizeof(word));
	return r;
}


enum exec_type
{
	COND_ALWAYS  = 0,
	COND_ZERO    = 1,
	COND_NONZERO = 2,
	COND_GREATER = 3,
	COND_LESS    = 4,
	COND_GEQUAL = 5,
	COND_LEQUAL  = 6,
};

enum input_type
{
	INPUT_ZERO = 0,
	INPUT_IMM  = 1,
	INPUT_PEEK = 2,
	INPUT_POP  = 3,
};

enum result_type
{
	OUTPUT_DISCARD = 0,
	OUTPUT_PUSH    = 1,
	OUTPUT_JUMP    = 2,
	OUTPUT_RJUMP   = 3,
};

enum command
{
	CMD_COPY = 0,
	CMD_IPGET = 1, 
	CMD_GET = 2,
	CMD_SET = 3,
	CMD_STORE8 = 4,
	CMD_STORE16 = 5,
	CMD_LOAD8 = 6,
	CMD_LOAD16 = 7,
	// = 8,
	// = 9,
	CMD_FRGET = 10,
	CMD_FRSET = 11,
	CMD_BPGET = 12,
	CMD_BPSET = 13,
	CMD_SPGET = 14,
	CMD_SPSET = 15,
	CMD_ADD   = 16,
	CMD_SUB   = 17,
	CMD_MUL   = 18,	
	CMD_DIV   = 19,
	CMD_MOD   = 20,
	CMD_AND   = 21,
	CMD_OR    = 22,
	CMD_XOR   = 23,
	CMD_NOT   = 24,
	CMD_NEG   = 25,
	CMD_ROL   = 26,
	CMD_ROR   = 27,
	CMD_BSWAP = 28,
	CMD_ASR   = 29,
	CMD_LSL   = 30,
	CMD_LSR   = 31,
};

struct __attribute__((packed)) instruction
{
	unsigned exec     : 3;
	unsigned input0   : 2;
	unsigned input1   : 2;
	unsigned flags    : 1;
	unsigned output   : 2;
	unsigned command  : 5;
	unsigned reserved : 1;

	constexpr instruction() :
		exec(0),
		input0(0), input1(0),
		flags(0), output(0),
		command(0), reserved(0)
	{

	}

	constexpr instruction(word w) :
		exec(w),
		input0(w>>3), input1(w>>5),
		flags(w>>7), output(w>>8),
		command(w>>10), reserved(w>>15)
	{
	
	}

	constexpr instruction(unsigned c, unsigned i0, unsigned i1, unsigned o, unsigned f = false, unsigned e = COND_ALWAYS) :
		exec(e),
		input0(i0), input1(i1),
		flags(f), output(o),
		command(c), reserved(0)
	{
	
	}

	constexpr operator word() const
	{
		return exec
			| (input0 << 3)
			| (input1 << 5)
			| (flags << 7)
			| (output << 8)
			| (command << 10)
			| (reserved << 15)
			;
	}
};
static_assert(sizeof(instruction) == 2);

struct memory
{
	word load16(word address) const
	{
		assert((address & 1) == 0);
		return load8(address) | (load8(address|1) << 8);
	}

	void store16(word address, word value)
	{
		assert((address & 1) == 0);
		store8(address|0, value & 0xFF);
		store8(address|1, value >> 8);
	}

	virtual byte load8(word address) const = 0;
	virtual void store8(word address, byte value) = 0;
};

template<size_t N>
struct bank_memory : memory
{
	static constexpr size_t bank_size = (1<<16) / N;
	static_assert((bank_size * N) == (1<<16), "N must be a divisor of 64k");
	std::array<memory*, N> banks;

	auto decode_address(word address) const
	{
		struct 
		{
			size_t bank, offset;
		} value {
			address / bank_size,
			address % bank_size
		};
		assert(value.bank < N);
		assert(value.offset < bank_size);
		return value;
	}
	
	byte load8(word address) const override
	{
		auto const [ bank, offset ] = decode_address(address);
		return banks[bank]->load8(offset);
	}

	void store8(word address, byte value) override
	{
		auto const [ bank, offset ] = decode_address(address);
		banks[bank]->store8(offset, value);
	}

	memory * & operator[](size_t i) { return banks[i]; }
};

template<size_t N>
struct ram : memory, std::array<byte, N>
{
	static_assert((N & (N-1)) == 0, "N must be a power of two!");

	using std::array<byte, N>::array;

	byte load8(word address) const override
	{
		return this->at(address % N);
	}

	void store8(word address, byte value) override
	{
		this->at(address % N) = value;
	}
};

template<size_t N>
struct rom : ram<N>
{
	using ram<N>::ram;
	// ROM doesn't store...
	void store8(word, byte) override { }
};

struct nil_memory : memory
{
	byte load8(word) const override { return 0xFF; }

	void store8(word, byte) override { }
} nil_memory;

struct cpu
{
	memory * memory;
	word SP, BP, IP, FR;
	word input0, input1, output;

	static constexpr word ZERO = (1<<0);
	static constexpr word NEGATIVE = (1<<1);
	static constexpr word MSB = (1<<15);

	explicit cpu(struct memory * mem) : memory(mem) { }

	void reset()
	{
		IP = 0x0000;
		FR = 0x0000;
	}

	void step()
	{
		instruction instr = memory->load16(IP);
		IP += 2;
		bool exec;
		switch(instr.exec)
		{
		case COND_ALWAYS: exec = true; break;
		case COND_ZERO:   exec = (FR & ZERO); break;
		case COND_NONZERO:  exec = !(FR & ZERO); break;
		case COND_GREATER: exec = !(FR&ZERO) and !(FR&NEGATIVE); break;
		case COND_LESS: exec = (FR & NEGATIVE); break;
		case COND_GEQUAL: exec = (FR&ZERO) or !(FR&NEGATIVE); break;
		case COND_LEQUAL:  exec = (FR&ZERO) or (FR&NEGATIVE); break;
		}
		if(not exec)
		{
			IP += 2*((instr.input0 == INPUT_IMM) + (instr.input1 == INPUT_IMM));
			return;
		}
		input0 = fetch_input(instr.input0);
		input1 = fetch_input(instr.input1);
		switch(instr.command)
		{
		case CMD_COPY:
			output = input0;
			break;
		case CMD_IPGET:
			output = IP + 2*input0;
			break;
		case CMD_GET:
			output = memory->load16(BP + 2 * input0);
			break;
		case CMD_SET:
			output = input1;
			memory->store16(BP + 2 * input0, input1);
			break;
		case CMD_STORE8:
			output = input1 & 0xFF;
			memory->store8(input0, input1 & 0xFF);
			break;
		case CMD_STORE16:
			output = input1;
			memory->store16(input0, input1);
			break;
		case CMD_LOAD8:
			output = memory->load8(input0);
			break;
		case CMD_LOAD16:
			output = memory->load16(input0);
			break;
		case CMD_FRGET:
			output = (FR & ~input1);
			break;
		case CMD_FRSET:
			FR = (input0 & ~input1);
			output = FR;
			break;
		case CMD_BPGET:
			output = BP;
			break;
		case CMD_BPSET:
			output = input0;
			BP = input0;
			break;
		case CMD_SPGET:
			output = SP;
			break;
		case CMD_SPSET:
			output = input0;
			SP = input0;
			break;
		case CMD_ADD:
			output = input0 + input1;
			break;
		case CMD_SUB:
			output = input0 - input1;
			break;
		case CMD_MUL:
			output = to_unsigned(to_signed(input0) * to_signed(input1));
			break;
		case CMD_DIV:
			output = to_unsigned(to_signed(input0) / to_signed(input1));
			break;
		case CMD_MOD:
			output = to_unsigned(to_signed(input0) % to_signed(input1));
			break;
		case CMD_AND:
			output = input0 & input1;
			break;
		case CMD_OR:
			output = input0 | input1;
			break;
		case CMD_XOR:
			output = input0 ^ input1;
			break;
		case CMD_NOT:
			output = ~input0;
			break;
		case CMD_NEG:
			output = to_unsigned(-to_signed(input0));
			break;
		case CMD_ROL:
			output = (input0 << 1)
			       | ((input0 & MSB) ? 1 : 0)
			       ;
			break;
		case CMD_ROR:
			output = (input0 >> 1)
			       | ((input0 & 1) ? MSB : 0)
			       ;
			break;
		case CMD_BSWAP:
			output = ((input0 >> 8) & 0xFF)
			       | ((input0 << 8) & 0xFF00);
			       ;
			break;
		case CMD_ASR:
			output = (MSB & input0)
			       | (input0 >> 1)
			       ;
			break;
		case CMD_LSL:
			output = (input0 << 1);
			break;
		case CMD_LSR:
			output = (input0 >> 1);
			break;
		}
		switch(instr.output)
		{
		case OUTPUT_DISCARD: break;
		case OUTPUT_PUSH: push(output); break;
		case OUTPUT_JUMP: IP = output; break;
		case OUTPUT_RJUMP: IP += 2*output; break;
		}
		if(instr.flags)
		{
			FR = (FR & ~(NEGATIVE | ZERO))
				| ((output == 0) ? ZERO : 0)
				| ((output & MSB) ? NEGATIVE : 0)
				;
		}
	}

	word fetch_input(unsigned int t)
	{
		word w;
		switch(t)
		{
		case INPUT_ZERO: w = 0; break;
		case INPUT_IMM:
			w = memory->load16(IP);
			IP += 2;
			break;
		case INPUT_PEEK: w = peek(); break;
		case INPUT_POP: w = pop(); break;
		}
		return w;
	}

	void push(word w)
	{
		SP += 2;
		memory->store16(SP, w);
	}

	word pop()
	{
		auto const w = peek();
		SP -= 2;
		return w;
	}

	word peek() const
	{
		return memory->load16(SP);
	}
};

int main()
{
	rom<(1<<14)> lower_quart
	{
	};
	ram<(1<<14)> lower_mid, upper_mid;

	bank_memory<4> banks;
	banks[0] = &lower_quart;
	banks[1] = &lower_mid;
	banks[2] = &upper_mid;
	banks[3] = &nil_memory;

	cpu cpu { &banks };
	cpu.reset();

	for(size_t i = 0; i < 100; i++)
	{
		cpu.step();
	}

	return 0;
}
