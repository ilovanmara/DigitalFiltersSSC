----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2023 06:43:52 PM
-- Design Name: 
-- Module Name: tb_filtruPrag - Behavioral
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
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_prag is
Port(
    sel: in std_logic
);
end tb_prag;

architecture Behavioral of tb_prag is

component FiltruPragAxi4 is
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
end component;

constant T : time := 100 ns;

signal aclk : STD_LOGIC := '0';
signal s_axis_a_tdata, s_axis_prag_tdata, m_axis_result_tdata: STD_LOGIC_VECTOR (15 downto 0);
signal s_axis_a_tready, s_axis_prag_tready : STD_LOGIC := '0';
signal s_axis_a_tvalid, s_axis_prag_tvalid : STD_LOGIC := '1';
signal m_axis_result_tvalid : STD_LOGIC := '1';

signal rd_count, wr_count, wr_count2 : integer := 0;
signal end_of_reading : std_logic := '0';


begin

   aclk <= not aclk after T / 2;
   
 dut: FiltruPragAxi4 Port map(
  aclk => aclk,
  s_axis_a_tvalid => s_axis_a_tvalid,
  s_axis_a_tready => s_axis_a_tready,
  s_axis_a_tdata => s_axis_a_tdata,
  s_axis_prag_tvalid => s_axis_prag_tvalid,
  s_axis_prag_tready => s_axis_prag_tready,
  s_axis_prag_tdata => s_axis_prag_tdata,
  m_axis_result_tvalid => m_axis_result_tvalid,
  m_axis_result_tready => '1',
  m_axis_result_tdata => m_axis_result_tdata
 );
   
    -- read values from the input file
    process (aclk)
        file sensors_data : text open read_mode is "C:\Users\mara_\Desktop\ssc\filtruPragFiles\filtruPrag.csv";
        variable in_line : line;
        
        variable temperature1 : std_logic_vector(15 downto 0);

    begin
    if sel = '1' then
        if rising_edge(aclk) then
            if end_of_reading = '0' then
            
                if not endfile(sensors_data) then     
                    
                    if s_axis_a_tready = '1' then     -- read from the file only when the module is ready to accept data              
                        readline(sensors_data, in_line);
                        s_axis_a_tvalid <= '1';
                        s_axis_prag_tvalid <= '1';
                        s_axis_prag_tdata <= x"0013";
                        read(in_line, temperature1); 
                        s_axis_a_tdata <= temperature1;
                        
                        rd_count <= rd_count + 1;
                        
                        report "Values measured successfully read";

                    end if;
                else
                    file_close(sensors_data);
                    end_of_reading <= '1';
                end if;
            end if;
        end if;
        end if;
    end process;
    
    -- write results in the output file
    process 
        file results : text open write_mode is "C:\Users\mara_\Desktop\ssc\filtruPragFiles\results6.csv"; -- TO DO: provide the absolute path of the project directory followed by "temperature_results.csv"
        variable out_line : line;
    begin
        wait until rising_edge(aclk);
    
        if wr_count <= rd_count and sel = '1' then
            if m_axis_result_tvalid = '1' then   -- write the result only when it is valid
                if (m_axis_result_tdata /= "ZZZZZZZZZZZZZZZZ") then
                    write(out_line, wr_count);
                    write(out_line, string'(", "));
                    write(out_line, m_axis_result_tdata);
                    writeline(results, out_line);
                    wr_count <= wr_count + 1;
                    --wr_count2 <= wr_count2 + 1;
                end if;
                --wr_count <= wr_count + 1;
            end if;
        else
            file_close(results);
            report "execution finished...";
            wait;
        end if;
    end process;
end Behavioral;
