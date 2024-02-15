----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 03:55:06 PM
-- Design Name: 
-- Module Name: scazator - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scazator is
  Port (
  rst: in std_logic;
    s_axis_X_tvalid:in std_logic;
    s_axis_X_tready: out std_logic;
    s_axis_X_tdata: in std_logic_vector (15 downto 0);
    s_axis_Y_tvalid:in std_logic;
    s_axis_Y_tready: out std_logic;
    s_axis_Y_tdata: in std_logic_vector (15 downto 0);
    m_axis_S_tvalid: out std_logic;
    m_axis_S_tready: in std_logic;
    m_axis_S_tdata: out std_logic_vector (15 downto 0)
   );
end scazator;

architecture Behavioral of scazator is

signal c: std_logic_vector (16 downto 0);
signal ready_read: std_logic := '0';
begin
 ready_read <= s_axis_X_tvalid and s_axis_Y_tvalid;
 s_axis_X_tready <= ready_read;
 s_axis_Y_tready <= ready_read;
 
m_axis_s_tdata <= s_axis_x_tdata - s_axis_y_tdata when ready_read = '1' else (others => '0');

m_axis_S_tvalid <= '1' when m_axis_S_tready = '1' and ready_read = '1' else '0';

end Behavioral;
