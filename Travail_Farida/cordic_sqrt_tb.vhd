library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_sqrt_tb is
end entity;

architecture tb of cordic_sqrt_tb is

    constant WL : positive := 16;
    constant FL : positive := 14;

    signal clk      : std_logic := '0';
    signal rst_n    : std_logic := '0';
    signal start    : std_logic := '0';
    signal a_in     : unsigned(WL-1 downto 0) := (others => '0');
    signal sqrt_out : unsigned(WL-1 downto 0);
    signal done     : std_logic;

    function real_to_uq14(x : real) return unsigned is
        variable tmp : integer;
    begin
        tmp := integer(x * real(2**FL) + 0.5);
        return to_unsigned(tmp, WL);
    end function;

    function uq14_to_real(x : unsigned) return real is
    begin
        return real(to_integer(x)) / real(2**FL);
    end function;

begin

    uut : entity work.cordic_sqrt_hyp
        port map (
            clk      => clk,
            rst_n    => rst_n,
            start    => start,
            a_in     => a_in,
            sqrt_out => sqrt_out,
            done     => done
        );

    clk <= not clk after 5 ns;

    process
        variable fix_v : real;
        variable ref_v : real;
    begin
        -- reset
        rst_n <= '0';
        start <= '0';
        a_in  <= (others => '0');
        wait for 20 ns;
        rst_n <= '1';
        wait for 20 ns;

        -- Test 1 : sqrt(0.0)
        a_in <= real_to_uq14(0.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(0.0);

        report "Test 1 : sqrt(0.0)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        -- Test 2 : sqrt(0.25)
        a_in <= real_to_uq14(0.25);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(0.25);

        report "Test 2 : sqrt(0.25)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        -- Test 3 : sqrt(0.5)
        a_in <= real_to_uq14(0.5);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(0.5);

        report "Test 3 : sqrt(0.5)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        -- Test 4 : sqrt(1.0)
        a_in <= real_to_uq14(1.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(1.0);

        report "Test 4 : sqrt(1.0)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        -- Test 5 : sqrt(2.0)
        a_in <= real_to_uq14(2.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(2.0);

        report "Test 5 : sqrt(2.0)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        -- Test 6 : sqrt(3.0)
        a_in <= real_to_uq14(3.0);
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until rising_edge(clk) and done = '1';

        fix_v := uq14_to_real(sqrt_out);
        ref_v := sqrt(3.0);

        report "Test 6 : sqrt(3.0)";
        report "sqrt_fix = " & real'image(fix_v) & "  sqrt_ref = " & real'image(ref_v);

        wait;
    end process;

end architecture;