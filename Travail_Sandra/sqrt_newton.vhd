library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sqrt_newton is
    generic (
        WL      : positive := 16;
        FL      : positive := 14;
        N_ITER  : positive := 6
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        start    : in  std_logic;
        a_in     : in  unsigned(WL-1 downto 0);   -- Q2.14
        sqrt_out : out unsigned(WL-1 downto 0);
        done     : out std_logic
    );
end entity;

architecture rtl of sqrt_newton is
    type state_t is (IDLE, ITERATE, DONE_ST);
    signal state : state_t := IDLE;

    signal a_reg, x_reg : unsigned(WL-1 downto 0) := (others => '0');
    signal iter         : integer range 0 to N_ITER := 0;
    signal y_reg        : unsigned(WL-1 downto 0) := (others => '0');
    signal done_reg     : std_logic := '0';
begin
    sqrt_out <= y_reg;
    done     <= done_reg;

    process(clk, rst_n)
        variable div_q    : unsigned(WL-1 downto 0);
        variable x_next   : unsigned(WL-1 downto 0);
        variable a_int    : integer;
        variable x_int    : integer;
        variable tmp      : integer;
    begin
        if rst_n = '0' then
            state    <= IDLE;
            a_reg    <= (others => '0');
            x_reg    <= (others => '0');
            y_reg    <= (others => '0');
            iter     <= 0;
            done_reg <= '0';

        elsif rising_edge(clk) then
            done_reg <= '0';

            case state is
                when IDLE =>
                    if start = '1' then
                        a_reg <= a_in;

                        if a_in = 0 then
                            x_reg <= (others => '0');
                            state <= DONE_ST;
                        else
                            -- estimation initiale simple
                            x_reg <= shift_right(a_in, 1) + to_unsigned(2**(FL-1), WL);
                            iter  <= 0;
                            state <= ITERATE;
                        end if;
                    end if;

                when ITERATE =>
                    if x_reg = 0 then
                        x_reg <= to_unsigned(1, WL);
                    else
                        -- division entière simplifiée en TB / étude
                        a_int := to_integer(a_reg);
                        x_int := to_integer(x_reg);
                        tmp   := (a_int * (2**FL)) / x_int;
                        div_q := to_unsigned(tmp, WL);
                        x_next := shift_right(x_reg + div_q, 1);
                        x_reg <= x_next;
                    end if;

                    if iter = N_ITER - 1 then
                        state <= DONE_ST;
                    else
                        iter <= iter + 1;
                    end if;

                when DONE_ST =>
                    y_reg    <= x_reg;
                    done_reg <= '1';
                    state    <= IDLE;
            end case;
        end if;
    end process;

end architecture;