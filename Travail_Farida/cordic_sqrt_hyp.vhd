library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_sqrt_hyp is
    generic (
        WL     : positive := 16;
        FL     : positive := 14;
        N_ITER : positive := 16;
        GROW   : positive := 4
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        start    : in  std_logic;
        a_in     : in  unsigned(WL-1 downto 0);  -- Q2.14, a >= 0
        sqrt_out : out unsigned(WL-1 downto 0);  -- Q2.14
        done     : out std_logic
    );
end entity;

architecture rtl of cordic_sqrt_hyp is

    -- GROW kept for generic compatibility with previous versions.
    constant UNUSED_GROW : positive := GROW;
    constant HALF_Q14    : unsigned(WL downto 0) := to_unsigned(2**(FL-1), WL+1);

    type state_t is (IDLE, ITERATE, DONE_ST);
    signal state : state_t := IDLE;

    signal a_reg        : unsigned(WL-1 downto 0) := (others => '0');
    signal x_reg        : unsigned(WL downto 0) := (others => '0');
    signal iter         : integer range 0 to N_ITER := 0;

    signal sqrt_reg     : unsigned(WL-1 downto 0) := (others => '0');
    signal done_reg     : std_logic := '0';

begin

    sqrt_out <= sqrt_reg;
    done     <= done_reg;

    process(clk, rst_n)
        variable a_int      : integer;
        variable x_int      : integer;
        variable div_int    : integer;
        variable x_next_int : integer;
        constant X_MAX      : integer := 2**(WL+1) - 1;
    begin
        if rst_n = '0' then
            state    <= IDLE;
            a_reg    <= (others => '0');
            x_reg    <= (others => '0');
            iter     <= 0;
            sqrt_reg <= (others => '0');
            done_reg <= '0';

        elsif rising_edge(clk) then
            done_reg <= '0';

            case state is

                when IDLE =>
                    if start = '1' then
                        a_reg <= a_in;
                        if a_in = 0 then
                            sqrt_reg <= (others => '0');
                            state    <= DONE_ST;
                        else
                            x_reg <= shift_right('0' & a_in, 1) + HALF_Q14;
                            iter  <= 0;
                            state <= ITERATE;
                        end if;
                    end if;

                when ITERATE =>
                    x_int := to_integer(x_reg);
                    if x_int = 0 then
                        x_reg <= to_unsigned(1, WL+1);
                    else
                        a_int := to_integer(a_reg);
                        div_int := (a_int * (2**FL)) / x_int;
                        x_next_int := (x_int + div_int) / 2;
                        if x_next_int > X_MAX then
                            x_reg <= to_unsigned(X_MAX, WL+1);
                        else
                            x_reg <= to_unsigned(x_next_int, WL+1);
                        end if;
                    end if;

                    if iter = N_ITER - 1 then
                        state <= DONE_ST;
                    else
                        iter <= iter + 1;
                    end if;

                when DONE_ST =>
                    if a_reg = 0 then
                        sqrt_reg <= (others => '0');
                    else
                        sqrt_reg <= resize(x_reg, WL);
                    end if;

                    done_reg <= '1';
                    state    <= IDLE;

            end case;
        end if;
    end process;

end architecture;
