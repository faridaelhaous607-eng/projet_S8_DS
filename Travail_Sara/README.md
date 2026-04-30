--cordic_multiply_hyp--

library ieee ;
use ieee . std_logic_1164 .all;
use ieee . numeric_std . all ;
entity cordic_multiply is
generic (
WL : positive := 16;
FL : positive := 14;
N_ITER : positive := 15
) ;
port (
clk : in std_logic ;
rst_n : in std_logic ;
start : in std_logic ;
in1 : in signed ( WL -1 downto 0) ; -- Q1 .14
in2 : in signed ( WL -1 downto 0) ; -- Q1 .14
out_p : out signed ( WL downto 0) ; -- Q2 .14
done : out std_logic
) ;
end entity ;

architecture rtl of cordic_multiply is

type state_t is ( IDLE , APPROX , DONE_ST ) ;
signal state , next_state : state_t := IDLE ;

signal x_reg : signed ( WL -1 downto 0) := ( others = > '0') ;
signal y_reg : signed ( WL downto 0) := ( others = > '0') ; -- 17 bits
signal z_reg : signed ( WL -1 downto 0) := ( others = > '0') ;
signal iter : integer range 0 to N_ITER := 0;

signal one_q14 : signed ( WL -1 downto 0) := to_signed (2** FL , WL ) ; -- 1.0

signal out_reg : signed ( WL downto 0) := ( others = > '0') ;
signal done_reg : std_logic := '0';
begin
out_p <= out_reg ;
done <= done_reg ;
 -- FSM registre d' tat

process ( clk , rst_n )
begin
if rst_n = '0' then
state <= IDLE ;
elsif rising_edge ( clk ) then
state <= next_state ;
end if;
end process ;
-- FSM logique de transition
process ( state , start , iter )
begin
case state is
when IDLE = >
if start = '1' then
next_state <= APPROX ;
else
next_state <= IDLE ;
end if;

when APPROX = >
if iter = N_ITER - 1 then
next_state <= DONE_ST ;
else
next_state <= APPROX ;
end if;
when DONE_ST = >
next_state <= IDLE ;
when others = >
next_state <= IDLE ;
end case ;
end process ;
 -- Calcul principal

process ( clk , rst_n )
variable y_next : signed ( WL downto 0) ;
variable z_next : signed ( WL -1 downto 0) ;
variable x_ext : signed ( WL downto 0) ;
begin
if rst_n = '0' then
x_reg <= ( others = > '0') ;
y_reg <= ( others = > '0') ;
z_reg <= ( others = > '0') ;
iter <= 0;
out_reg <= ( others = > '0') ;
elsif rising_edge ( clk ) then
case state is
-- IDLE : initialisation

when IDLE = >
if start = '1' then
x_reg <= in1 ;
y_reg <= ( others = > '0') ;
z_reg <= in2 ;
iter <= 0;
end if;
 -- APPROX : accumulation i t rative

when APPROX = >
x_ext := resize ( shift_right ( x_reg , iter ) , WL +1) ;
if z_reg ( WL -1) = '0' then
y_next := y_reg + x_ext ;
z_next := z_reg - shift_right ( one_q14 , iter ) ;
else
y_next := y_reg - x_ext ;
z_next := z_reg + shift_right ( one_q14 , iter ) ;
end if;
y_reg <= y_next ;
z_reg <= z_next ;
if iter < N_ITER then
iter <= iter + 1;
end if;
-- DONE : sortie finale c o r r i g e
when DONE_ST = >
out_reg <= y_reg ;

end case ;
end if;
end process ;
-- done

process ( clk , rst_n )
begin
if rst_n = '0' then
done_reg <= '0';
elsif rising_edge ( clk ) then
case state is
when IDLE = >
done_reg <= '0';
when DONE_ST = >
done_reg <= '1';
when others = >
done_reg <= done_reg ;
end case ;
end if;
end process ;

end architecture ;



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
