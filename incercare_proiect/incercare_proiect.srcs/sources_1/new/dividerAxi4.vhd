----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2023 03:23:22 PM
-- Design Name: 
-- Module Name: divider - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dividerAxi4 is
  Port ( 
   aclk : in STD_LOGIC;
   aresetn: in STD_LOGIC;
   s_axis_a_tvalid: in std_logic;
   s_axis_a_tready : out STD_LOGIC;
   s_axis_a_tdata : in STD_LOGIC_VECTOR(15 downto 0);
   s_axis_b_tvalid: in std_logic;
   s_axis_b_tready : out STD_LOGIC;
   s_axis_b_tdata : in STD_LOGIC_VECTOR(15 downto 0);
   m_axis_quotient_tvalid : out STD_LOGIC;
   m_axis_quotient_tready : in STD_LOGIC;
   m_axis_quotient_tdata : out STD_LOGIC_VECTOR(15 downto 0);
   m_axis_remainder_tvalid : out STD_LOGIC;
   m_axis_remainder_tready : in STD_LOGIC;
   m_axis_remainder_tdata : out STD_LOGIC_VECTOR(15 downto 0)
  );
end dividerAxi4;

architecture Behavioral of dividerAxi4 is

type State_Type is (IDLE, DIVIDE, stop);
    signal state : State_Type := IDLE;
    signal counter : integer := 0;
    signal quotient_reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal a_reg, b_reg: std_logic_vector (31 downto 0);
    signal ready_read: std_logic := '0';
    signal s: std_logic := '1';
    signal sign: std_logic := '0';
    --signal rst: std_logic := '1';
   
begin
ready_read <= (s_axis_a_tvalid and s_axis_b_tvalid) and m_axis_quotient_tready;
s_axis_a_tready <= ready_read when state = IDLE;
s_axis_b_tready <= ready_read when state = IDLE;

 process(aclk, aresetn)
    begin
        if rising_edge(aclk) then
            case state is
                when IDLE =>
                    if s = '1' and ready_read = '1' then  
                        quotient_reg <= (others=>'0');
--                        a_reg <= X"0000" & s_axis_a_tdata;
--                        b_reg <= s_axis_b_tdata & X"0000";
                         sign <= s_axis_a_tdata(15) xor s_axis_b_tdata(15);
                              if s_axis_a_tdata(15) = '0' then
                                   a_reg <= X"0000" & s_axis_a_tdata;
                              else a_reg <= X"0000" & (not s_axis_a_tdata + x"0001");
                              end if;
                              if s_axis_b_tdata(15) = '0' then
                                    b_reg <= s_axis_b_tdata & X"0000";
                              else b_reg <= (not s_axis_b_tdata + x"0001") & X"0000";
                              end if;
                        state <= DIVIDE;
                    end if;
                when DIVIDE =>
                    if counter < 17 then 
                        if a_reg >= b_reg then
                            a_reg <= a_reg - b_reg;
                            quotient_reg(15 downto 1) <= quotient_reg(14 downto 0);
                            quotient_reg(0) <= '1'; 
                        else 
                            quotient_reg(15 downto 1) <= quotient_reg(14 downto 0);
                            quotient_reg(0) <= '0';
                        end if;
                        b_reg(30 downto 0) <= b_reg(31 downto 1);
                        b_reg(31) <= '0';
                        counter <= counter + 1;
                    else state <= stop;
                    end if;
                 
                when stop =>
                    if sign = '0' then
                        m_axis_quotient_tdata <= quotient_reg;
                    else 
                        m_axis_quotient_tdata <= (not quotient_reg) + x"0001";
                    end if;
                    if (m_axis_quotient_tready = '1') then 
                        m_axis_quotient_tvalid <= '1';
                    else  m_axis_quotient_tvalid <= '0';
                    end if;
                    if (m_axis_remainder_tready = '1') then
                         m_axis_remainder_tvalid <= '1';
                    else m_axis_remainder_tvalid <= '0';
                    end if;
                    if aresetn = '1' then
                        state <= IDLE;
                        counter <= 0;
                    end if;
            end case;

        end if;
    end process;
    --aresetn <= rst;
    ready_read <= '0' when state = stop else '1';
    --m_axis_quotient_tdata <= quotient_reg;
    m_axis_remainder_tdata <= a_reg(15 downto 0);

end Behavioral;
