library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_trig_tb is
end entity;

architecture tb of cordic_trig_tb is

    constant WL     : positive := 16;
    constant FL     : positive := 14;
    constant N_ITER : positive := 15;

    constant PI_C : real := 3.14159265358979323846;

    signal clk      : std_logic := '0';
    signal rst_n    : std_logic := '0';
    signal start    : std_logic := '0';
    signal angle_in : signed(WL-1 downto 0) := (others => '0');
    signal cos_out  : signed(WL-1 downto 0);
    signal sin_out  : signed(WL-1 downto 0);
    signal done     : std_logic;

    function real_to_q14(x : real) return signed is
        variable tmp : integer;
    begin
        if x >= 0.0 then
            tmp := integer(x * real(2**FL) + 0.5);
        else
            tmp := integer(x * real(2**FL) - 0.5);
        end if;
        return to_signed(tmp, WL);
    end function;

    function q14_to_real(x : signed) return real is
    begin
        return real(to_integer(x)) / real(2**FL);
    end function;

begin

    uut : entity work.cordic_trig
        generic map (
            WL     => WL,
            FL     => FL,
            N_ITER => N_ITER
        )
        port map (
            clk      => clk,
            rst_n    => rst_n,
            start    => start,
            angle_in => angle_in,
            cos_out  => cos_out,
            sin_out  => sin_out,
            done     => done
        );

    clk <= not clk after 5 ns;

    process
        variable c_ref, s_ref : real;
        variable c_fix, s_fix : real;
    begin
        -- reset
        rst_n <= '0';
        start <= '0';
        angle_in <= (others => '0');
        wait for 20 ns;
        rst_n <= '1';
        wait for 20 ns;

        -- Test 1 : 0°
        angle_in <= real_to_q14(0.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(0.0);
        s_ref := sin(0.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 1 : 0 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 2 : 45°
        angle_in <= real_to_q14(PI_C / 4.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(PI_C / 4.0);
        s_ref := sin(PI_C / 4.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 2 : 45 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 3 : -45°
        angle_in <= real_to_q14(-PI_C / 4.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(-PI_C / 4.0);
        s_ref := sin(-PI_C / 4.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 3 : -45 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 4 : 90°
        angle_in <= real_to_q14(PI_C / 2.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(PI_C / 2.0);
        s_ref := sin(PI_C / 2.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 4 : 90 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 5 : -90°
        angle_in <= real_to_q14(-PI_C / 2.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(-PI_C / 2.0);
        s_ref := sin(-PI_C / 2.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 5 : -90 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 6 : 30°
        angle_in <= real_to_q14(PI_C / 6.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(PI_C / 6.0);
        s_ref := sin(PI_C / 6.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 6 : 30 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 7 : -60°
        angle_in <= real_to_q14(-PI_C / 3.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(-PI_C / 3.0);
        s_ref := sin(-PI_C / 3.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 7 : -60 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        -- Test 8 : 8.16°
        angle_in <= real_to_q14(8.16 * PI_C / 180.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        c_ref := cos(8.16 * PI_C / 180.0);
        s_ref := sin(8.16 * PI_C / 180.0);
        c_fix := q14_to_real(cos_out);
        s_fix := q14_to_real(sin_out);

        report "Test 8 : 8.16 deg";
        report "cos_fix = " & real'image(c_fix) & "  cos_ref = " & real'image(c_ref);
        report "sin_fix = " & real'image(s_fix) & "  sin_ref = " & real'image(s_ref);

        wait;
    end process;

end architecture;