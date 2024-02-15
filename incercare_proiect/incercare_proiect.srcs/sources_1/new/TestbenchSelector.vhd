----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2024 03:01:10 PM
-- Design Name: 
-- Module Name: TestbenchSelector - Behavioral
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

entity TestbenchSelector is
  Port ( 
  select_simulation: in std_logic_vector(2 downto 0)
  );
end TestbenchSelector;

architecture Behavioral of TestbenchSelector is

begin

filtru1: entity work.tb_prag
port map (
sel => select_simulation(0)
);

filtru2: entity work.tb_medie
port map (
sel => select_simulation(1)
);

filtru3: entity work.tb_interpolare
port map (
sel => select_simulation(2)
);


end Behavioral;
