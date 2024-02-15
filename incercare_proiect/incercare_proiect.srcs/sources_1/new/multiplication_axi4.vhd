----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 12:32:04 PM
-- Design Name: 
-- Module Name: multiplication - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplication is
  Port ( 
  Clk: in std_logic;
  Rst: in std_logic;
  s_axis_a_tvalid: in std_logic;
  s_axis_a_tready : out STD_LOGIC;
  s_axis_a_tdata : in STD_LOGIC_VECTOR(15 downto 0);
  s_axis_b_tvalid: in std_logic;
  s_axis_b_tready : out STD_LOGIC;
  s_axis_b_tdata : in STD_LOGIC_VECTOR(15 downto 0);
  m_axis_res_tvalid : out STD_LOGIC;
  m_axis_res_tready : in STD_LOGIC;
  m_axis_res_tdata : out STD_LOGIC_VECTOR(15 downto 0)
  );
end multiplication;

architecture Behavioral of multiplication is

type State_Type is (IDLE, MULTIPLY, STOP);
signal state : State_Type := IDLE;
signal counter : integer := 0;
signal q : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal a_reg, b_reg: std_logic_vector (31 downto 0);
signal s: std_logic := '1';
signal ready_read: std_logic := '0';
signal sign: std_logic := '0';
begin

ready_read <= s_axis_a_tvalid and s_axis_b_tvalid and m_axis_res_tready;
s_axis_a_tready <= ready_read when state = IDLE;
s_axis_b_tready <= ready_read when state = IDLE;

 process(clk, rst)
    begin
--       if rst = '1' then
--              state <= IDLE;
--       end if;
       if rising_edge(clk) then
            case state is
                when IDLE =>
                    if s = '1' and ready_read = '1' then  
                        sign <= s_axis_a_tdata(15) xor s_axis_b_tdata(15);
                        if s_axis_b_tdata(15) = '1' then
                            q <= (not s_axis_b_tdata) + x"0001"; 
                        else
                            q <= s_axis_b_tdata; 
                        end if;
                        a_reg <= (others => '0');
                        if s_axis_a_tdata(15) = '0' then
                            b_reg <= X"0000" & s_axis_a_tdata;
                        else 
                            b_reg <= X"0000" & (not s_axis_a_tdata + x"0001");
                        end if;
                        state <= MULTIPLY;
                   end if;
                when MULTIPLY =>
                    if counter < 16 then 
                        if q(0) = '1' then
                            a_reg <= a_reg + b_reg;
                        end if;
                        b_reg <= b_reg(30 downto 0) & '0';
                        q <= '0' & q(15 downto 1);
                        counter <= counter + 1;
                    else 
                        state <= STOP;
                    end if;
                when STOP =>
                    if (m_axis_res_tready = '1') then 
                        m_axis_res_tvalid <= '1';
                    end if;               
                    if rst = '1' then
                        state <= IDLE;
                        counter <= 0;
                    end if;
                    if sign = '0' then
                         m_axis_res_tdata <= a_reg(15 downto 0);
                    else 
                        m_axis_res_tdata <= (not a_reg(15 downto 0)) + x"0001";
                   end if;
            end case;

        end if;
    end process;
    ready_read <= '0' when state = stop else '1';
    s <= '1' when state = idle else  '0';
    --done <= '1' when state = stop else '0';
 --   m_axis_res_tdata <= a_reg(15 downto 0);


end Behavioral;
