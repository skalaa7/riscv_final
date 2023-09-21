LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.util_pkg.all;


ENTITY ALU IS
   GENERIC(
      WIDTH : NATURAL := 32);
   PORT(
      clk    : in std_logic;
      reset  : in std_logic;
      stall_o: out std_logic;
      a_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --first input
      b_i    : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --second input
      op_i   : in alu_op_t; --operation select
      res_o  : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)); --result
      --zero_o : out STD_LOGIC; --zero flag
      --of_o   : out STD_LOGIC; --overflow flag
END ALU;

ARCHITECTURE behavioral OF ALU IS
  
  component multiply
    Port (clk   : in std_logic;
      reset : in std_logic;
      con_s : in std_logic_vector(1 downto 0);
      a_in  : in std_logic_vector(31 downto 0);
      b_in  : in std_logic_vector(31 downto 0);
      c_out  : out std_logic_vector(63 downto 0);
      stall_status: out std_logic;
      start_status: in std_logic   
     );            
    end component;
   
   component division_u
   Port (clk           : in std_logic;
      reset         : in std_logic;
      start_i       : in std_logic;
      SorU          : in std_logic;
      dividend_i    : in std_logic_vector(31 downto 0);
      divisor_i     : in std_logic_vector(31 downto 0);
      quotient_o    : out std_logic_vector(31 downto 0);
      remainder_o   : out std_logic_vector(31 downto 0);
      stall_o       : out std_logic);
   end component; 
    
   constant  l2WIDTH : natural := integer(ceil(log2(real(WIDTH))));
   signal    lts_res,ltu_res,add_res,sub_res,or_res,and_res,res_s,xor_res  :  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
   signal    eq_res,sll_res,srl_res,sra_res : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
   signal    b_u: integer := 0; 
   --signal    divu_res,divs_res,rems_res,remu_res : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
   --signal    muls_res,mulu_res : STD_LOGIC_VECTOR(2*WIDTH-1 DOWNTO 0);	
   --signal    mulsu_res : STD_LOGIC_VECTOR(2*WIDTH+1 DOWNTO 0);
   
--   constant mulu_op: std_logic_vector (4 downto 0):="01001"; ---> multiply lower
--   constant mulhs_op: std_logic_vector (4 downto 0):="01010"; ---> multiply higher signed
--   constant mulhsu_op: std_logic_vector (4 downto 0):="01011"; ---> multiply higher signed and unsigned
--   constant mulhu_op: std_logic_vector (4 downto 0):="01100"; ---> multiply higher unsigned
--   constant divu_op: std_logic_vector (4 downto 0):="01101"; ---> divide unsigned
--   constant divs_op: std_logic_vector (4 downto 0):="01110"; ---> divide signed
--   constant remu_op: std_logic_vector (4 downto 0):="01111"; ---> reminder unsigned
--   constant rems_op: std_logic_vector (4 downto 0):="10000"; ---> reminder signed

   signal stall, start : std_logic;	
   signal ready_s,valid_s, SorU: std_logic; 
   signal con_s: std_logic_vector(1 downto 0) := (others => '0');
   signal    mul_res: std_logic_vector(2*WIDTH-1 downto 0);
   signal    rem_res, div_res : std_logic_vector(WIDTH-1 downto 0);

   attribute use_dsp : string;
   attribute use_dsp of Behavioral : architecture is "yes";

BEGIN
   b_u <= to_integer(unsigned(b_i(4 downto 0)));
   
   inst_mul: multiply 
   port map(
       clk => clk,
       reset => reset,
       a_in => a_i,
       b_in => b_i,
       con_s => con_s,
       c_out =>  mul_res,
       stall_status => stall,
       start_status => start
   ); 
   
   
       
   inst_div_s: division_u
   port map(
      clk => clk,
      reset => reset,
      start_i => valid_s,
      SorU    => SorU,
      dividend_i => a_i,
      divisor_i  => b_i,
      quotient_o => div_res,
      remainder_o => rem_res,
      stall_o  =>  ready_s
   );   

   -- addition
   add_res <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
   -- subtraction
   sub_res <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
   -- and gate
   and_res <= a_i and b_i;
   -- or gate
   or_res <= a_i or b_i;
   -- xor gate
   xor_res <= a_i xor b_i;
   -- equal
   --eq_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) = signed(b_i)) else
             --std_logic_vector(to_unsigned(0,WIDTH));
   -- less then signed
   lts_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) < signed(b_i)) else
              std_logic_vector(to_unsigned(0,WIDTH));
   -- less then unsigned
   ltu_res <= std_logic_vector(to_unsigned(1,WIDTH)) when (unsigned(a_i) < unsigned(b_i)) else
              std_logic_vector(to_unsigned(0,WIDTH));
   --shift results
   sll_res <= std_logic_vector(shift_left(unsigned(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
   srl_res <= std_logic_vector(shift_right(unsigned(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
   sra_res <= std_logic_vector(shift_right(signed(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
   --multiplication
   --muls_res <= std_logic_vector(signed(a_i)*signed(b_i));
   --mulsu_res <= std_logic_vector(signed(a_i(WIDTH-1) & a_i)*signed('0' & b_i)); 
   --mulu_res <= std_logic_vector(unsigned(a_i)*unsigned(b_i));
   --division
   --divs_res <= std_logic_vector(signed(a_i)/signed(b_i)) when b_i /= std_logic_vector(to_unsigned(0,WIDTH)) else
   --            (others => '1');
   --divu_res <= std_logic_vector(unsigned(a_i)/unsigned(b_i)) when b_i /= std_logic_vector(to_unsigned(0,WIDTH)) else
   --            (others => '1');
   --mode
   --rems_res <= std_logic_vector(signed(a_i) rem signed(b_i)) when b_i /= std_logic_vector(to_unsigned(0,WIDTH)) else
   --            (others => '1');
   --remu_res <= std_logic_vector(unsigned(a_i) rem unsigned(b_i)) when b_i /= std_logic_vector(to_unsigned(0,WIDTH)) else
   --           (others => '1');
   
   -- SELECT RESULT
   res_o <= res_s;
   with op_i select
      res_s <= and_res when and_op, --and
      or_res when or_op, --or
      xor_res when xor_op, --xor
      add_res when add_op, --add (changed opcode)
      sub_res when sub_op, --sub
      --eq_res when eq_op, -- set equal
      lts_res when lts_op, -- set less than signed
      ltu_res when ltu_op, -- set less than unsigned
      sll_res when sll_op, -- shift left logic
      srl_res when srl_op, -- shift right logic
      sra_res when sra_op, -- shift right arithmetic
      mul_res(31 downto 0) when mulu_op, --signed lower
      mul_res(63 downto 32) when mulhs_op, -- signed high
      mul_res(63 downto 32) when mulhu_op,-- unsigned high
      mul_res (63 downto 32) when mulhsu_op,
      std_logic_vector(div_res) when divu_op,
      std_logic_vector(div_res) when divs_op,
      std_logic_vector(rem_res) when remu_op,
      std_logic_vector(rem_res) when rems_op,
      --mulu_res(WIDTH-1 downto 0) when mulu_op, -- multiply lower
      --muls_res(2*WIDTH-1 downto WIDTH) when mulhs_op, -- multiply higher signed
      --mulsu_res(2*WIDTH-1 downto WIDTH) when mulhsu_op, -- multiply higher signed and unsigned
      --mulu_res(2*WIDTH-1 downto WIDTH) when mulhu_op, -- multiply higher unsigned
      --divu_res when divu_op, -- divide unsigned
      --divs_res when divs_op, -- divide signed
      --remu_res when remu_op, -- reminder signed
      --rems_res when rems_op, -- reminder signed
      (others => '1') when others; 
    
      process(op_i, stall, ready_s)
    begin
        start <= '0';
        valid_s <= '0';
        stall_o <= '1';
        SorU    <= '0';
        con_s <= "00";
        case op_i is
            when mulu_op => 
                start <= '1';
                stall_o <= stall;
                con_s <= "00";
            when mulhs_op =>
                start <= '1';
                stall_o <= stall; 
                con_s <= "00";
            when mulhu_op =>
                start <= '1';
                stall_o <= stall;
                con_s <= "11";
            when mulhsu_op =>
                start <= '1';
                stall_o <= stall;
                con_s <= "01";
            when divu_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '0';
            when divs_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '1';
            when remu_op =>
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '0';
            when rems_op =>    
                valid_s <= '1';
                stall_o <= ready_s;
                SorU    <= '1';
            when others => 
                start <= '0';
                stall_o <= '1';
                valid_s <= '0';
        end case;
    end process;
--    addition: if op_i=add_op generate
--        res_s <= std_logic_vector(unsigned(a_i) + unsigned(b_i));
--    end generate;
--    subtraction: if op_i=sub_op generate
--        res_s <= std_logic_vector(unsigned(a_i) - unsigned(b_i));
--    end generate;
--    and_gate: if op_i=and_op generate
--        res_s <= a_i and b_i;
--    end generate;
--    or_gate: if op_i=or_op generate
--        res_s <= a_i or b_i;
--    end generate;
--    xor_gate: if op_i=xor_op generate
--        res_s <= a_i xor b_i;
--    end generate;
----    equal: if op_i=eq_op generate
----        res_s <= a_i or b_i;
----    end generate;
--    less_than_signed: if op_i=lts_op generate
--        res_s <= std_logic_vector(to_unsigned(1,WIDTH)) when (signed(a_i) < signed(b_i)) else
--                 std_logic_vector(to_unsigned(0,WIDTH));
--    end generate;
--    less_than_unsigned: if op_i=ltu_op generate
--        res_s <= std_logic_vector(to_unsigned(1,WIDTH)) when (unsigned(a_i) < unsigned(b_i)) else
--                 std_logic_vector(to_unsigned(0,WIDTH));
--    end generate;
--    shift_left_logic: if op_i=sll_op generate
--        res_s <= std_logic_vector(shift_left(unsigned(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
--    end generate;
--    shift_right_logic: if op_i=srl_op generate
--        res_s <= std_logic_vector(shift_right(unsigned(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
--    end generate;
--    shift_right_arithmetic: if op_i=sra_op generate
--        res_s <= std_logic_vector(shift_right(signed(a_i), to_integer(unsigned(b_i(l2WIDTH downto 0)))));
--    end generate;

   -- flag outputs
   -- set zero output flag when result is zero
   --zero_o <= '1' when res_s = std_logic_vector(to_unsigned(0,WIDTH)) else
             --'0';
   -- overflow happens when inputs have same sign, and output has different
   --of_o <= '1' when ((op_i=add_op and (a_i(WIDTH-1)=b_i(WIDTH-1)) and ((a_i(WIDTH-1) xor res_s(WIDTH-1))='1')) or (op_i=sub_op and (a_i(WIDTH-1)=res_s(WIDTH-1)) and ((a_i(WIDTH-1) xor b_i(WIDTH-1))='1'))) else '0';


END behavioral;
