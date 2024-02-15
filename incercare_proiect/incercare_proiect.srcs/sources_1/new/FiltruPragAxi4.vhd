----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2023 06:10:39 PM
-- Design Name: 
-- Module Name: FiltruPragAxi4 - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FiltruPragAxi4 is
  Port (
  aclk : IN STD_LOGIC;
  s_axis_a_tvalid : IN STD_LOGIC;
  s_axis_a_tready : OUT STD_LOGIC;
  s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  s_axis_prag_tvalid : IN STD_LOGIC;
  s_axis_prag_tready : OUT STD_LOGIC;
  s_axis_prag_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  m_axis_result_tvalid : OUT STD_LOGIC;
  m_axis_result_tready : IN STD_LOGIC;
  m_axis_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
end FiltruPragAxi4;

architecture Behavioral of FiltruPragAxi4 is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

signal res_valid : STD_LOGIC := '0';
signal result : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

signal a_ready, b_ready, op_ready : STD_LOGIC := '0';
signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';
signal gt : std_logic:='0';
signal en : std_logic:='0';
begin

s_axis_a_tready <= external_ready;
s_axis_prag_tready <= external_ready;

internal_ready <= '1' when state = READ_OPERANDS else '0';
inputs_valid <= s_axis_a_tvalid and s_axis_prag_tvalid; 
external_ready <= internal_ready and inputs_valid;

m_axis_result_tvalid <= '1' when state = WRITE_RESULT else '0';
m_axis_result_tdata <= result;


process(aclk)

 variable temp : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    if rising_edge(aclk) then
        case state is
            when READ_OPERANDS =>
                 if external_ready = '1' and inputs_valid = '1' then
                    if (s_axis_a_tdata <= s_axis_prag_tdata) then
                        --result <= s_axis_a_tdata;
                        temp := s_axis_a_tdata;
                        state <= WRITE_RESULT;
                        gt <= '1';
                    else 
                        temp := "ZZZZZZZZZZZZZZZZ";
                        gt <= '0';
                    end if;
                    result <= temp;
                end if;
            when WRITE_RESULT =>
                if m_axis_result_tready = '1' and gt = '1' then
                    state <= READ_OPERANDS;
                    
                end if;
            end case;
    end if;
end process;
                

end Behavioral;
