library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_trig is
    generic (
        WL     : positive := 16;
        FL     : positive := 14;
        N_ITER : positive := 15
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        start    : in  std_logic;
        angle_in : in  signed(WL-1 downto 0);  -- Q1.14, radians
        cos_out  : out signed(WL-1 downto 0);
        sin_out  : out signed(WL-1 downto 0);
        done     : out std_logic
    );
end entity;

architecture rtl of cordic_trig is

    type atan_array_t is array (0 to N_ITER-1) of signed(WL-1 downto 0);

    constant ATAN_TABLE : atan_array_t := (
        0  => to_signed(12868, WL), -- atan(2^-0)  ≈ 0.785400
        1  => to_signed( 7596, WL), -- atan(2^-1)  ≈ 0.463623
        2  => to_signed( 4014, WL), -- atan(2^-2)  ≈ 0.244995
        3  => to_signed( 2037, WL), -- atan(2^-3)  ≈ 0.124329
        4  => to_signed( 1023, WL), -- atan(2^-4)  ≈ 0.062439
        5  => to_signed(  512, WL), -- atan(2^-5)  ≈ 0.031250
        6  => to_signed(  256, WL), -- atan(2^-6)  ≈ 0.015625
        7  => to_signed(  128, WL), -- atan(2^-7)  ≈ 0.007812
        8  => to_signed(   64, WL), -- atan(2^-8)  ≈ 0.003906
        9  => to_signed(   32, WL), -- atan(2^-9)  ≈ 0.001953
        10 => to_signed(   16, WL), -- atan(2^-10) ≈ 0.000977
        11 => to_signed(    8, WL), -- atan(2^-11) ≈ 0.000488
        12 => to_signed(    4, WL), -- atan(2^-12) ≈ 0.000244
        13 => to_signed(    2, WL), -- atan(2^-13) ≈ 0.000122
        14 => to_signed(    1, WL)  -- atan(2^-14) ≈ 0.000061
    );

    constant K_INIT : signed(WL-1 downto 0) := to_signed(9949, WL); -- 0.607253 * 2^14

    type state_t is (IDLE, ROTATE, DONE_ST);
    signal state : state_t := IDLE;

    signal x_reg, y_reg, z_reg : signed(WL-1 downto 0) := (others => '0');
    signal iter                : integer range 0 to N_ITER := 0;

    signal cos_reg, sin_reg    : signed(WL-1 downto 0) := (others => '0');
    signal done_reg            : std_logic := '0';

begin

    cos_out <= cos_reg;
    sin_out <= sin_reg;
    done    <= done_reg;

    process(clk, rst_n)
        variable x_old, y_old, z_old : signed(WL-1 downto 0);
        variable x_next, y_next, z_next : signed(WL-1 downto 0);
    begin
        if rst_n = '0' then
            state   <= IDLE;
            x_reg   <= (others => '0');
            y_reg   <= (others => '0');
            z_reg   <= (others => '0');
            iter    <= 0;
            cos_reg <= (others => '0');
            sin_reg <= (others => '0');
            done_reg <= '0';

        elsif rising_edge(clk) then
            done_reg <= '0';

            case state is

                when IDLE =>
                    if start = '1' then
                        x_reg <= K_INIT;
                        y_reg <= (others => '0');
                        z_reg <= angle_in;
                        iter  <= 0;
                        state <= ROTATE;
                    end if;

                when ROTATE =>
                    x_old := x_reg;
                    y_old := y_reg;
                    z_old := z_reg;

                    if z_old(WL-1) = '0' then
                        x_next := x_old - shift_right(y_old, iter);
                        y_next := y_old + shift_right(x_old, iter);
                        z_next := z_old - ATAN_TABLE(iter);
                    else
                        x_next := x_old + shift_right(y_old, iter);
                        y_next := y_old - shift_right(x_old, iter);
                        z_next := z_old + ATAN_TABLE(iter);
                    end if;

                    x_reg <= x_next;
                    y_reg <= y_next;
                    z_reg <= z_next;

                    if iter = N_ITER - 1 then
                        state <= DONE_ST;
                    else
                        iter <= iter + 1;
                    end if;

                when DONE_ST =>
                    cos_reg  <= x_reg;
                    sin_reg  <= y_reg;
                    done_reg <= '1';
                    state    <= IDLE;

            end case;
        end if;
    end process;

end architecture;
