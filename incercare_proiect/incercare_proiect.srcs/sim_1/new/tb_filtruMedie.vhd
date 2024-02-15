----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2023 06:32:49 PM
-- Design Name: 
-- Module Name: tb_filtruMedie - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_filtruMedie is

end tb_filtruMedie;

architecture Behavioral of tb_filtruMedie is

component FiltruDeMedie is
Port (
   aclk : in STD_LOGIC;
   aresetn: in STD_LOGIC;
   rst: in std_logic;
   s_axis_x1_tvalid: in std_logic;
   s_axis_x1_tready : out STD_LOGIC;
   s_axis_x1_tdata : in STD_LOGIC_VECTOR(15 DOWNTO 0);
   s_axis_x2_tvalid: in std_logic;
   s_axis_x2_tready : out STD_LOGIC;
   s_axis_x2_tdata : in STD_LOGIC_VECTOR(15 downto 0);
   s_axis_x3_tvalid: in std_logic;
   s_axis_x3_tready : out STD_LOGIC;
   s_axis_x3_tdata : in STD_LOGIC_VECTOR(15 downto 0);
   s_axis_x4_tvalid : in STD_LOGIC;
   s_axis_x4_tready : out STD_LOGIC;
   s_axis_x4_tdata : in STD_LOGIC_VECTOR (15 downto 0);
   s_axis_d_tvalid : in STD_LOGIC;
   s_axis_d_tready : out STD_LOGIC;
   s_axis_d_tdata : in STD_LOGIC_VECTOR (15 downto 0);
   m_axis_result_tvalid : out STD_LOGIC;
   m_axis_result_tready : in STD_LOGIC;
   m_axis_result_tdata : out STD_LOGIC_VECTOR(15 downto 0);
   m_axis_r_tvalid : out STD_LOGIC;
   m_axis_r_tready : in STD_LOGIC;
   m_axis_r_tdata : out STD_LOGIC_VECTOR(15 downto 0)
 );
end component;

constant T : time := 20 ns;
constant T2 : time := 420 ns;
constant T3 : time := 380 ns;
signal aclk, aresetn, clk, clk_wr : STD_LOGIC := '0';
signal rst: std_logic := '0';
signal axis_x1_tdata, axis_x2_tdata, axis_x3_tdata, axis_x4_tdata, axis_d_tdata, axis_result_tdata, axis_r_tdata : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal axis_x1_tready, axis_x2_tready, axis_x3_tready, axis_d_tready, axis_x4_tready, axis_result_tready, axis_r_tready : STD_LOGIC := '0';
signal axis_x1_tvalid, axis_x2_tvalid, axis_x3_tvalid, axis_x4_tvalid, axis_d_tvalid, axis_result_tvalid, axis_r_tvalid : STD_LOGIC := '1';

signal rd_count, wr_count : integer := 0;
signal end_of_reading : std_logic := '0';

begin
clk_wr <= not clk_wr after T3 / 2;
clk <= not clk after T2 / 2;
aclk <= not aclk after T / 2;
aresetn <= '0', '1' after 5 * T;

process (aclk, aresetn)
begin
    if rising_edge(aclk) then
        if axis_result_tvalid = '1' then
            rst <= '1';  
        else
            rst <= '0'; 
        end if;
    end if;
end process;

dut: FiltruDeMedie port map (
        aclk => aclk,
        aresetn=> aresetn,
        rst => rst,
        s_axis_x1_tvalid => axis_x1_tvalid,
        s_axis_x1_tready => axis_x1_tready,
        s_axis_x1_tdata => axis_x1_tdata,
        s_axis_x2_tvalid => axis_x2_tvalid,
        s_axis_x2_tready => axis_x2_tready,
        s_axis_x2_tdata  => axis_x2_tdata,
        s_axis_x3_tvalid => axis_x3_tvalid,
        s_axis_x3_tready => axis_x3_tready,
        s_axis_x3_tdata => axis_x3_tdata,
        s_axis_x4_tvalid => axis_x4_tvalid,
        s_axis_x4_tready => axis_x4_tready,
        s_axis_x4_tdata => axis_x4_tdata,
        s_axis_d_tvalid => axis_d_tvalid,
        s_axis_d_tready => axis_d_tready,
        s_axis_d_tdata => axis_d_tdata,
        m_axis_result_tvalid => axis_result_tvalid,
        m_axis_result_tready => '1', 
        m_axis_result_tdata => axis_result_tdata,
        m_axis_r_tvalid => axis_r_tvalid,
        m_axis_r_tready => '1',
        m_axis_r_tdata => axis_r_tdata
);
  
    -- read values from the input file
    process (clk)
        file sensors_data : text open read_mode is "temp.csv";
        variable in_line1 : line;
        variable in_line2 : line;
        variable in_line3 : line;
        variable in_line4 : line;
        variable in_line : line;
        variable temperature1 : std_logic_vector(15 downto 0);
        variable temperature2 : std_logic_vector(15 downto 0);
        variable temperature3 : std_logic_vector(15 downto 0);
        variable temperature4 : std_logic_vector(15 downto 0);
        variable temperature : std_logic_vector(15 downto 0);
        variable space : character;
        variable comma : character;
        variable save_line1 : line;
        variable save_line2 : line;
        variable save_line3 : line;
        variable save_line4 : line;
        variable count: integer := 0;
        
    begin
  
        if rising_edge(aclk) then
            --aresetn = '0';
            if aresetn = '1' and end_of_reading = '0' then
          
                if not endfile(sensors_data) then     
                    
                    if axis_x1_tready = '1' and axis_x2_tready = '1' and axis_x3_tready = '1' and axis_x4_tready = '1' and axis_d_tready = '1'  then     -- read from the file only when the module is ready to accept data
                        if count = 0 then
                            readline(sensors_data, in_line1);
                            readline(sensors_data, in_line2);
                            readline(sensors_data, in_line3);
                            readline(sensors_data, in_line4);
                            read(in_line1, temperature1);
                            read(in_line2, temperature2);
                            read(in_line3, temperature3);
                            read(in_line4, temperature4);
                        else 
                            temperature1 := temperature2;
                            temperature2 := temperature3;
                            temperature3 := temperature4;
                            readline(sensors_data, in_line4);
                            read(in_line4, temperature4);
                        end if;
                        
                            axis_x1_tvalid <= '1';
                            axis_x2_tvalid <= '1';
                            axis_x3_tvalid <= '1';
                            axis_x4_tvalid <= '1';
                            axis_d_tvalid <= '1';
  
                        axis_result_tready <= '0';
                        axis_r_tready <= '0';
                       
                        axis_x1_tdata <= temperature1;
                        axis_x2_tdata <= temperature2;
                        axis_x3_tdata <= temperature3;
                        axis_x4_tdata <= temperature4; 
          
                        count := count + 1;
                        
                        axis_d_tdata <= x"0004";
                        
                        rd_count <= rd_count + 1;
                                              
                        report "Values measured successfully read";
                    else  
                        axis_x1_tvalid <= '0';
                        axis_x2_tvalid <= '0';
                        axis_x3_tvalid <= '0';
                        axis_x4_tvalid <= '0';
                        axis_d_tvalid <= '0';
                        axis_result_tready <= '1';
                        axis_r_tready <= '1';
                    end if;
                        
                else
                    file_close(sensors_data);
                    end_of_reading <= '1';
                end if;
            end if;
        end if;
    
    end process;
    
    -- write results in the output file
    process 
        file results : text open write_mode is "C:\Users\mara_\Desktop\ssc\test_pr\results.csv"; -- TO DO: provide the absolute path of the project directory followed by "temperature_results.csv"
        variable out_line : line;
    begin
        wait until rising_edge(clk_wr);
       
         if aresetn = '0' then
               wait until rising_edge(aresetn);
         end if;
         
         --wait until axis_result_tvalid  = '1';
    
        if wr_count <= rd_count then
            if axis_result_tvalid = '1' then   -- write the result only when it is valid
                write(out_line, wr_count);
                write(out_line, string'(", "));
                write(out_line, axis_result_tdata);
                writeline(results, out_line);
                
                wr_count <= wr_count + 1;
            end if;
        else
            file_close(results);
            report "execution finished...";
            wait;
        end if;
    end process;


end Behavioral;
