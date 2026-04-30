--cordic_multiply_tb--
library ieee ;
use ieee . std_logic_1164 .all;
use ieee . numeric_std . all ;
use ieee . math_real .all ;
entity cordic_multiply_tb is
end entity ;
architecture tb of cordic_multiply_tb is

constant WL : positive := 16;
constant FL : positive := 14;
constant N_ITER : positive := 15;
signal clk : std_logic := '0';
signal rst_n : std_logic := '0';
signal start : std_logic := '0';
signal in1 : signed ( WL -1 downto 0) := ( others = > '0') ;
signal in2 : signed ( WL -1 downto 0) := ( others = > '0') ;
signal out_p : signed ( WL downto 0) ;
signal done : std_logic ;

function real_to_q14 ( x : real ) return signed is
variable tmp : integer ;
begin
if x >= 0.0 then
tmp := integer ( x * real (2** FL ) + 0.5) ;
else
tmp := integer ( x * real (2** FL ) - 0.5) ;
end if;
return to_signed ( tmp , WL ) ;
end function ;
function q14_to_real ( x : signed ) return real is
begin
return real ( to_integer ( x ) ) / real (2** FL ) ;
end function ;
begin
uut : entity work . cordic_multiply
generic map (
WL = > WL ,
FL = > FL ,
N_ITER = > N_ITER
)
port map (
48 clk = > clk ,
rst_n = > rst_n ,
start = > start ,
in1 = > in1 ,
in2 = > in2 ,
out_p = > out_p ,
done = > done
) ;
clk <= not clk after 5 ns ;

process
variable ref_v : real ;
variable fix_v : real ;
begin

-- Reset

rst_n <= '0';
start <= '0';
in1 <= ( others = > '0') ;
in2 <= ( others = > '0') ;
wait for 20 ns ;
rst_n <= '1';
wait for 20 ns ;

-- Test 1 : 0 * 0.75

in1 <= real_to_q14 (0.0) ;
in2 <= real_to_q14 (0.75) ;
wait until rising_edge ( clk ) ;
start <= '1';
wait until rising_edge ( clk ) ;
start <= '0';
wait until rising_edge ( clk ) and done = '1';

ref_v := 0.0 * 0.75;
fix_v := q14_to_real ( out_p ) ;
report " Test 1 : 0 * 0.75";
report " out_fix = " & real ' image ( fix_v ) & " out_ref = " & real '
image ( ref_v ) ;

-- Test 2 : 0.5 * 0.5

in1 <= real_to_q14 (0.5) ;
in2 <= real_to_q14 (0.5) ;
wait until rising_edge ( clk ) ;
start <= '1';
wait until rising_edge ( clk ) ;
start <= '0';
wait until rising_edge ( clk ) and done = '1';

ref_v := 0.5 * 0.5;
fix_v := q14_to_real ( out_p ) ;
report " Test 2 : 0.5 * 0.5";
report " out_fix = " & real ' image ( fix_v ) & " out_ref = " & real '
image ( ref_v ) ;

-- Test 3 : -0.5 * 0.5

in1 <= real_to_q14 (0.5) ;
in2 <= real_to_q14 ( -0.5) ;
wait until rising_edge ( clk ) ;
start <= '1';
wait until rising_edge ( clk ) ;
start <= '0';
wait until rising_edge ( clk ) and done = '1';

ref_v := 0.5 * ( -0.5) ;
fix_v := q14_to_real ( out_p ) ;
report " Test 3 : -0.5 * 0.5";
report " out_fix = " & real ' image ( fix_v ) & " out_ref = " & real '
image ( ref_v ) ;

-- Test 4 : 1.9999 * 1.9999

in1 <= real_to_q14 (1.9999) ;
in2 <= real_to_q14 (1.9999) ;
wait until rising_edge ( clk ) ;
start <= '1';
wait until rising_edge ( clk ) ;
start <= '0';
wait until rising_edge ( clk ) and done = '1';

ref_v := 1.9999 * 1.9999;
fix_v := q14_to_real ( out_p ) ;
report " Test 4 : 1.9999 * 1.9999";
report " out_fix = " & real ' image ( fix_v ) & " out_ref = " & real '
image ( ref_v ) ;

-- Test 5 : 1.9999 * -1.9999

in1 <= real_to_q14 (1.9999) ;
in2 <= real_to_q14 ( -1.9999) ;
wait until rising_edge ( clk ) ;
start <= '1';
wait until rising_edge ( clk ) ;
start <= '0';
wait until rising_edge ( clk ) and done = '1';

ref_v := 1.9999 * ( -1.9999) ;
fix_v := q14_to_real ( out_p ) ;
report " Test 5 : 1.9999 * -1.9999";
report " out_fix = " & real ' image ( fix_v ) & " out_ref = " & real '
image ( ref_v ) ;
wait ;
end process ;

end architecture ;