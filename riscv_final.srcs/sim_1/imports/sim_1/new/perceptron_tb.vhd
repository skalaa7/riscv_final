----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2023 04:24:34 PM
-- Design Name: 
-- Module Name: perceptron_tb - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--use work.pkg.all;
entity perceptron_tb is
--  Port ( );
end perceptron_tb;

architecture Behavioral of perceptron_tb is
constant weight_num: natural :=5;
constant weight_size: natural :=8;
--type weights_i_2d is array (weight_num-1 downto 0) of
--    std_logic_vector(weight_size-1 downto 0);
signal weight_s:std_logic_vector(weight_num*weight_size-1 downto 0);
signal x_s: std_logic_vector(weight_num-2 downto 0);
signal y_s:std_logic;
begin
perceptron1:entity work.perceptron(Behavioral)
    generic map(
        weight_num=>weight_num,
        weight_size=>weight_size
    )
    port map(
        weight_i=>weight_s,
        x_i=>x_s,
        y_o=>y_s
    );
for1: for i in 0 to weight_num-1 generate
    weight_s(i*weight_size+weight_size-1 downto i*weight_size)<=std_logic_vector(to_signed(-2*i+5,weight_size));
end generate;
for2: for i in 0 to weight_num-2 generate
    
    x_s(i)<='1';
end generate;
end Behavioral;
