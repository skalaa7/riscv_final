----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2022 07:24:09 PM
-- Design Name: 
-- Module Name: scalar_core_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;

entity scalar_core_tb is
-- port ();
end entity;


architecture Behavioral of scalar_core_tb is
   -- Operand za pristup asemblerskom kodu programa
   file RISCV_instructions: text open read_mode is "../../../../div_test1.txt";   
   -- Globalni signali
   signal clk: std_logic:='0';
   signal reset: std_logic;
   signal ce: std_logic;
   signal instr_ready_s: std_logic;
   signal data_ready_s: std_logic;
   signal fencei_s: std_logic;
   signal pc_reg_s: std_logic;      
   -- Signali memorije za instrukcije
   signal ena_instr_s,enb_instr_s: std_logic;
   signal wea_instr_s,web_instr_s: std_logic_vector(3 downto 0);
   signal addra_instr_s,addrb_instr_s: std_logic_vector(9 downto 0);
   signal dina_instr_s,dinb_instr_s:std_logic_vector(31 downto 0);
   signal douta_instr_s,doutb_instr_s:std_logic_vector(31 downto 0);
   signal addrb_instr_32_s:std_logic_vector(31 downto 0);
   -- Signali memorije za podatke
   signal ena_data_s,enb_data_s: std_logic;
   signal rea_data_s : std_logic;
   signal wea_data_s,web_data_s:std_logic_vector(3 downto 0);
   signal addra_data_s,addrb_data_s: std_logic_vector(9 downto 0);
   signal dina_data_s,dinb_data_s:std_logic_vector(31 downto 0);
   signal douta_data_s,doutb_data_s:std_logic_vector(31 downto 0);
   signal addra_data_32_s:std_logic_vector(31 downto 0);
   -- Vector signali
   signal all_v_stores_executed_s:std_logic;
   signal all_v_loads_executed_s:std_logic;
   signal vector_stall_s: std_logic;
   signal scalar_load_req_s :std_logic;
   signal scalar_store_req_s :std_logic;
   signal v_instruction_s : std_logic_vector(31 downto 0);
   signal rs1_s : std_logic_vector(31 downto 0);
   signal rs2_s : std_logic_vector(31 downto 0);
   --simulation regs
   signal if_phase1,id_phase2,ex_phase3,mem_phase4,wb_phase5: std_logic_vector(31 downto 0);

begin

   -- Memorija za instrukcije
   -- Pristup A : Koristi se za inicijalizaciju memorije za instrukcije
   -- Pristup B : Koristi se za citanje instrukcija od strane procesora 
	-- Konstante:
   ena_instr_s   <= '1';
   enb_instr_s   <= '1';
   data_ready_s  <= '1';
   instr_ready_s <= '1';
   vector_stall_s<= '0';
   ce            <= '1';
   all_v_stores_executed_s <= '0';
   all_v_loads_executed_s <= '0';
   addrb_instr_s <= addrb_instr_32_s(9 downto 0);
   web_instr_s   <= (others => '0');
   dinb_instr_s  <= (others => '0');
	-- Instanca:
   instruction_mem: entity work.BRAM(behavioral)
      generic map(WADDR   => 10)
      port map (clk       => clk,
                -- pristup A
                en_a_i    => ena_instr_s,
                we_a_i    => wea_instr_s,
                addr_a_i  => addra_instr_s,
                data_a_i  => dina_instr_s,
                data_a_o  => douta_instr_s,
                -- pristup B
                en_b_i    => enb_instr_s,
                we_b_i    => web_instr_s,
                addr_b_i  => addrb_instr_s,
                data_b_i  => dinb_instr_s,
                data_b_o  => doutb_instr_s);


   -- Memorija za podatke
   -- Pristup A : Koristi procesor kako bi upisivao i citao podatke
   -- Pristup B : Ne koristi se
	-- Konstante:
   addra_data_s <= addra_data_32_s(9 downto 0);
   addrb_data_s <= (others => '0');
   dinb_data_s  <= (others => '0');
	ena_data_s   <= '1';
	enb_data_s   <= '1';
	-- Instanca:
   data_mem: entity work.BRAM(behavioral)
      generic map(WADDR   => 10)
      port map (clk       => clk,
                -- pristup A
                en_a_i    => ena_data_s,
                we_a_i    => wea_data_s,
                addr_a_i  => addra_data_s,
                data_a_i  => dina_data_s,
                data_a_o  => douta_data_s,
                -- pristup B
                en_b_i    => enb_data_s,
                we_b_i    => web_data_s,
                addr_b_i  => addrb_data_s,
                data_b_i  => dinb_data_s,
                data_b_o  => doutb_data_s);


   -- Top Modul - RISCV procesor jezgro
   TOP_RISCV_1: entity work.scalar_core
      port map (
         clk                    => clk,
         ce                     => ce,
         reset                  => reset,
         instr_ready_i          => instr_ready_s,
         data_ready_i           => data_ready_s,
         
         instr_mem_read_i       => doutb_instr_s,
         instr_mem_address_o    => addrb_instr_32_s,
                          
         data_mem_we_o          => wea_data_s,
         data_mem_re_o          => rea_data_s,
         data_mem_address_o     => addra_data_32_s,
         data_mem_read_i        => douta_data_s,
         data_mem_write_o       => dina_data_s);
   
   -- Inicijalizacija memorije za instrukcije
   -- Program koji ce procesor izvrsavati se ucitava u memoriju
   read_file_proc:process
      variable row: line;
      variable i: integer:= 0;
   begin
      reset <= '0';
      wea_instr_s <= (others => '1');
      while (not endfile(RISCV_instructions))loop         
         readline(RISCV_instructions, row);
         addra_instr_s <= std_logic_vector(to_unsigned(i, 10));
         dina_instr_s <= to_std_logic_vector(string(row));         
         i := i + 4;
         wait until rising_edge(clk);
      end loop;
      wea_instr_s <= (others => '0');
      reset <= '1' after 20 ns;
      wait;
   end process;

   -- klok signal generator
   clk_proc: process
   begin
      clk <= '1', '0' after 100 ns;
      wait for 200 ns;
   end process;
   
   --simulation
   if_phase1<=doutb_instr_s;
   sim_reg:process(clk)is
   begin
        if(rising_edge(clk)) then
            id_phase2<=if_phase1;
            ex_phase3<=id_phase2;
            mem_phase4<=ex_phase3;
            wb_phase5<=mem_phase4; 
        end if; 
   end process;
end architecture;

