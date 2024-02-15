----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2024 03:58:13 PM
-- Design Name: 
-- Module Name: tb_final - Behavioral
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

entity tb_final is
--  Port ( );
end tb_final;

architecture Behavioral of tb_final is

signal s: std_logic_vector(2 downto 0);

begin

final_comp: entity work.TestbenchSelector
port map (
select_simulation => s
);

process
begin
s <= "010";
wait;
end process;


end Behavioral;
