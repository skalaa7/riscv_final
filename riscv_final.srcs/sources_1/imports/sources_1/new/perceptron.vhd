----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 05:47:49 PM
-- Design Name: 
-- Module Name: perceptron - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package mypack is
    function f_log2 (x : positive) return natural;   
end package mypack;
package body mypack is
function f_log2 (x : positive) return natural is
      variable i : natural;
   begin
      i := 0;  
      while (2**i < x) and i < 31 loop
         i := i + 1;
      end loop;
      return i;
   end function;
end mypack;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.util_pkg.all;
entity perceptron is
    
    
    generic(weight_num: natural :=6;
            weight_size: natural:=8);
    Port (--clk: in std_logic;
          weight_i: in std_logic_vector(weight_num*weight_size-1 downto 0);--weights_i_2d;
          x_i: in std_logic_vector(weight_num-2 downto 0);
          y_o: out std_logic
     );
end perceptron;

architecture Behavioral of perceptron is
constant ONE:   UNSIGNED(clogb2(weight_num)+weight_size-1 downto 0) := (0 => '1', others => '0');
type weights_i_2d is array (weight_num-1 downto 0) of
std_logic_vector(weight_size-1 downto 0);
type operands_i_2d is array (weight_num-1 downto 0) of
std_logic_vector(clogb2(weight_num)+weight_size-1 downto 0);
signal y_res: std_logic_vector(clogb2(weight_num)+weight_size-1 downto 0);
signal op_s: operands_i_2d;
signal x_s: std_logic_vector(weight_num-1 downto 0);
type res_t_2d is array (2*weight_num-2 downto 0) of
std_logic_vector(clogb2(weight_num)+weight_size-1 downto 0);
signal temp_res : res_t_2d;
type upper_2d is array (weight_num-1 downto 0) of std_logic_vector(clogb2(weight_num)-1 downto 0);
signal upper_s : upper_2d ;
signal weight_2d_s:weights_i_2d;
--attribute use_dsp : string;
  -- attribute use_dsp of Behavioral : architecture is "yes";
begin
--process (clk) is
--    begin
--    if(rising_edge(clk)) then
        x_s<='1'&x_i;
 --  end if;   
 --   end process;
for0: for i in 0 to weight_num-1 generate
    weight_2d_s(i)<=weight_i(i*weight_size+weight_size-1 downto i*weight_size);
end generate;
for1: for i in 0 to weight_num-1 generate
    for2: for j in upper_s(i)'range generate
    upper_s(i)(j)<=weight_2d_s(i)(weight_size-1);
    end generate;
end generate;

muxes: for i in 0 to weight_num-1 generate
  -- process (clk) is
  --  begin
  -- if(rising_edge(clk)) then
    op_s(i)<=upper_s(i)&weight_2d_s(i);
  --  end if;   
 --  end process;
end generate;
for3: for i in 0 to weight_num-1 generate
    temp_res(i)<=op_s(i) when x_s(i)='1' else std_logic_vector(-signed(unsigned(op_s(i))));
end generate;
addition: for i in 0 to weight_num-2 generate
    temp_res(weight_num+i)<=std_logic_vector(signed(temp_res(2*i))+signed(temp_res(2*i+1)));
end generate;
y_res<=temp_res(2*weight_num-2);
--y_res<=std_logic_vector(signed(op_s(0))+signed(op_s(1))+signed(op_s(2))
--+signed(op_s(3))+signed(op_s(4))+signed(op_s(5))+signed(op_s(6))+signed(op_s(7)));
--process(clk) is
--begin
--if(rising_edge(clk)) then
y_o<= '1' when signed(y_res)>0 else '0';
--end if;
--end process;
end Behavioral;
