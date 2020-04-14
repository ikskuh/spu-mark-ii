-- Debug Port receiver

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

ENTITY DebugPortSender IS
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
END ENTITY DebugPortSender;

ARCHITECTURE rtl OF DebugPortSender IS
  TYPE TState IS (Idle, TransmitHigh, TransmitLow );

  CONSTANT limit : natural := (freq_clk / (2 * baud)) - 1;

  constant limit_width : integer := INTEGER(CEIL(LOG2(REAL(limit+1))));

  SIGNAL state : TState ;
  SIGNAL pos : unsigned(3 downto 0);
	SIGNAL output_buffer : std_logic_vector(6 downto 0);
  SIGNAL divider : unsigned(limit_width downto 0);
begin

	p0: process(rst, clk)
	begin
		if rst = '0' then
			state <= Idle;
      pos <= to_unsigned(0, pos'length);
      complete <= '0';
    elsif rising_edge(clk) then
      case state is
        when Idle =>
          complete <= '0';
          if txd = '1' then
            state <= TransmitHigh;
            pos <= to_unsigned(7, pos'length);
            divider <= to_unsigned(0, divider'length);
            output_buffer <= txd_data(6 downto 0);
            dbg_clk  <= '1';
            dbg_data <= txd_data(7);
          end if;

        when TransmitHigh =>
          if divider = limit then
            divider <= to_unsigned(0, divider'length);
            state <= TransmitLow;
            dbg_clk  <= '0';
            dbg_data <= '0';
          else
            divider <= divider + 1;
          end if;

        when TransmitLow =>
          if divider = limit then
            if pos = 0 then
              state <= Idle;
              complete <= '1';
              dbg_clk  <= '0';
              dbg_data <= '0';
            else
              state <= TransmitHigh;
              pos <= pos - 1;
              dbg_clk  <= '1';
              dbg_data <= output_buffer(to_integer(pos - 1));
            end if;
            divider <= to_unsigned(0, divider'length);
          else
            divider <= divider + 1;
          end if;

      end case;

    end if;
	end process;

end architecture;