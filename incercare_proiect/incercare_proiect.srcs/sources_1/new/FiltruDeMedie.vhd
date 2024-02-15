----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2023 03:52:41 PM
-- Design Name: 
-- Module Name: FiltruDeMedie - Behavioral
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

entity FiltruDeMedie is
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
end FiltruDeMedie;

architecture Behavioral of FiltruDeMedie is

COMPONENT fifo
  PORT (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    axis_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

component dividerAxi4 
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
end component;

component sumatorAxi4 
  Port ( 
  clk: in std_logic;
  rst : in std_logic;
  s_axis_Cin_tvalid : in std_logic;
  s_axis_Cin_tready : out std_logic;
  s_axis_Cin_tdata : in std_logic;
  s_axis_X_tvalid:in std_logic;
  s_axis_X_tready: out std_logic;
  s_axis_X_tdata: in std_logic_vector (15 downto 0);
  s_axis_Y_tvalid:in std_logic;
  s_axis_Y_tready: out std_logic;
  s_axis_Y_tdata: in std_logic_vector (15 downto 0);
  m_axis_Cout_tvalid: in std_logic;
  m_axis_Cout_tready: out std_logic;
  m_axis_Cout_tdata: out std_logic;
  m_axis_S_tvalid: out std_logic;
  m_axis_S_tready: in std_logic;
  m_axis_S_tdata: out std_logic_vector (15 downto 0)
  );
end component;

   signal x1_tvalid, start_valid, d_tvalid:  std_logic;
   signal x1_tready, d_tready: STD_LOGIC;
   signal x1_tdata, d_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
   signal x2_tvalid: std_logic;
   signal x2_tready : STD_LOGIC;
   signal x2_tdata : STD_LOGIC_VECTOR(15 downto 0);
   signal x3_tvalid: std_logic;
   signal x4_tvalid: std_logic;
   signal x3_tready, cout1, cout2, cout3, cout1_tready, cout1_tvalid, cout2_tready, cout2_tvalid, cout3_tready, cout3_tvalid, x4_tready : STD_LOGIC;
   signal x3_tdata : STD_LOGIC_VECTOR(15 downto 0);
   signal sum1_tvalid, sum2_tvalid, sum3_tvalid, cin1_tready, cin2_tready, cin3_tready : STD_LOGIC;
   signal sum1_tready, sum2_tready, sum3_tready : STD_LOGIC := '0';
   signal x4_tdata, sum1, sum2, sum3, axis_sum1, axis_sum2, axis_sum3 : STD_LOGIC_VECTOR (15 downto 0);
   signal result_tvalid, r_tvalid, reset : STD_LOGIC;
   signal result_tready, r_tready : STD_LOGIC;
   signal result_tdata, r_tdata  : STD_LOGIC_VECTOR(15 downto 0);
   signal axis_cout1, axis_cout2, axis_cout3, axis_cout1_tready, axis_cout1_tvalid, axis_cout2_tready, axis_cout2_tvalid, axis_cout3_tready, axis_cout3_tvalid : STD_LOGIC;
   signal axis_sum1_tvalid, axis_sum2_tvalid, axis_sum3_tvalid, axis_cin1_tready, axis_cin2_tready, axis_cin3_tready : STD_LOGIC;
   signal axis_sum1_tready, axis_sum2_tready, axis_sum3_tready : STD_LOGIC;
   signal temp1_data_count, temp2_data_count, temp3_data_count, temp4_data_count, res_data_count, r_data_count : STD_LOGIC_VECTOR (31 downto 0);
   signal temp1_wr_data_count, temp2_wr_data_count, temp3_wr_data_count, temp4_wr_data_count, res_wr_data_count, r_wr_data_count : STD_LOGIC_VECTOR (31 downto 0);
 signal temp1_rd_data_count, temp2_rd_data_count, temp3_rd_data_count, temp4_rd_data_count, res_rd_data_count, r_rd_data_count : STD_LOGIC_VECTOR (31 downto 0);
 signal temp5_wr_data_count, temp6_wr_data_count, temp7_wr_data_count, temp8_wr_data_count: std_logic_vector (31 downto 0);
 signal temp5_rd_data_count, temp6_rd_data_count, temp7_rd_data_count, temp8_rd_data_count: std_logic_vector (31 downto 0);
 signal temp5_data_count, temp6_data_count, temp7_data_count, temp8_data_count: std_logic_vector (31 downto 0);
signal ready_read: std_logic := '0';
signal r_ready, r_valid: std_logic;
signal r_data: std_logic_vector(15 downto 0);
begin

fifo_in_1: fifo
  PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => s_axis_x1_tvalid,
    s_axis_tready => s_axis_x1_tready,
    s_axis_tdata => s_axis_x1_tdata,
    m_axis_tvalid => x1_tvalid,
    m_axis_tready => x1_tready,
    m_axis_tdata => x1_tdata,
    axis_data_count => temp1_data_count,
    axis_wr_data_count => temp1_wr_data_count,
    axis_rd_data_count => temp1_rd_data_count
  );
  
fifo_in_2: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_x2_tvalid,
      s_axis_tready => s_axis_x2_tready,
      s_axis_tdata => s_axis_x2_tdata,
      m_axis_tvalid => x2_tvalid,
      m_axis_tready => x2_tready,
      m_axis_tdata => x2_tdata,
      axis_data_count => temp2_data_count,
      axis_wr_data_count => temp2_wr_data_count,
      axis_rd_data_count => temp2_rd_data_count
    );
fifo_in_3: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_x3_tvalid,
      s_axis_tready => s_axis_x3_tready,
      s_axis_tdata => s_axis_x3_tdata,
      m_axis_tvalid => x3_tvalid,
      m_axis_tready => x3_tready,
      m_axis_tdata => x3_tdata,
      axis_data_count => temp3_data_count,
      axis_wr_data_count => temp3_wr_data_count,
      axis_rd_data_count => temp3_rd_data_count
  );

  
sumator1: sumatorAxi4 
    Port map( 
    clk => aclk,
    rst => rst,
    s_axis_Cin_tvalid => '1',
    s_axis_Cin_tready => cin1_tready,
    s_axis_Cin_tdata => '0',
    s_axis_X_tvalid => x1_tvalid,
    s_axis_X_tready => x1_tready,
    s_axis_X_tdata => x1_tdata,
    s_axis_Y_tvalid => x2_tvalid,
    s_axis_Y_tready => x2_tready,
    s_axis_Y_tdata => x2_tdata,
    m_axis_Cout_tvalid => cout1_tvalid,
    m_axis_Cout_tready => cout1_tready,
    m_axis_Cout_tdata => cout1,
    m_axis_S_tvalid => sum1_tvalid,
    m_axis_S_tready => sum1_tready,
    m_axis_S_tdata => sum1
    );
    
fifo_in_5: fifo
   PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => sum1_tvalid,
      s_axis_tready => sum1_tready,
      s_axis_tdata => sum1,
      m_axis_tvalid => axis_sum1_tvalid,
      m_axis_tready => axis_sum1_tready,
      m_axis_tdata => axis_sum1,
      axis_data_count => temp5_data_count,
      axis_wr_data_count => temp5_wr_data_count,
      axis_rd_data_count => temp5_rd_data_count
  );
    
sumator2: sumatorAxi4 
 Port map( 
    clk => aclk,
    rst => rst,
    s_axis_Cin_tvalid => '1',
    s_axis_Cin_tready => cin1_tready,
    s_axis_Cin_tdata => '0',
    s_axis_X_tvalid => axis_sum1_tvalid,
    s_axis_X_tready => axis_sum1_tready,
    s_axis_X_tdata => axis_sum1,
    s_axis_Y_tvalid => x3_tvalid,
    s_axis_Y_tready => x3_tready,
    s_axis_Y_tdata => x3_tdata,
    m_axis_Cout_tvalid => cout2_tvalid,
    m_axis_Cout_tready => cout2_tready,
    m_axis_Cout_tdata => cout2,
    m_axis_S_tvalid => sum2_tvalid,
    m_axis_S_tready => sum2_tready,
    m_axis_S_tdata => sum2
 );
 
fifo_in_6: fifo
    PORT MAP(
       s_axis_aresetn => aresetn,
       s_axis_aclk  => aclk,
       s_axis_tvalid => sum2_tvalid,
       s_axis_tready => sum2_tready,
       s_axis_tdata => sum2,
       m_axis_tvalid => axis_sum2_tvalid,
       m_axis_tready => axis_sum2_tready,
       m_axis_tdata => axis_sum2,
       axis_data_count => temp6_data_count,
       axis_wr_data_count => temp6_wr_data_count,
       axis_rd_data_count => temp6_rd_data_count
   );
fif0_in_4: fifo
     PORT MAP(
       s_axis_aresetn => aresetn,
       s_axis_aclk  => aclk,
       s_axis_tvalid => s_axis_x4_tvalid,
       s_axis_tready => s_axis_x4_tready,
       s_axis_tdata => s_axis_x4_tdata,
       m_axis_tvalid => x4_tvalid,
       m_axis_tready => x4_tready,
       m_axis_tdata => x4_tdata,
       axis_data_count => temp4_data_count,
       axis_wr_data_count => temp4_wr_data_count,
       axis_rd_data_count => temp4_rd_data_count
     );
 
sumator3: sumatorAxi4 
  Port map( 
    clk => aclk,
    rst => rst,
     s_axis_Cin_tvalid => '1',
     s_axis_Cin_tready => cin1_tready,
     s_axis_Cin_tdata => '0',
     s_axis_X_tvalid => axis_sum2_tvalid,
     s_axis_X_tready => axis_sum2_tready,
     s_axis_X_tdata => axis_sum2,
     s_axis_Y_tvalid => x4_tvalid,
     s_axis_Y_tready => x4_tready,
     s_axis_Y_tdata => x4_tdata,
     m_axis_Cout_tvalid => cout3_tvalid,
     m_axis_Cout_tready => cout3_tready,
     m_axis_Cout_tdata => cout3,
     m_axis_S_tvalid => sum3_tvalid,
     m_axis_S_tready => sum3_tready,
     m_axis_S_tdata => sum3
  );
fifo_in_7: fifo
      PORT MAP(
         s_axis_aresetn => aresetn,
         s_axis_aclk  => aclk,
         s_axis_tvalid => sum3_tvalid,
         s_axis_tready => sum3_tready,
         s_axis_tdata => sum3,
         m_axis_tvalid => axis_sum3_tvalid,
         m_axis_tready => axis_sum3_tready,
         m_axis_tdata => axis_sum3,
         axis_data_count => temp7_data_count,
         axis_wr_data_count => temp7_wr_data_count,
         axis_rd_data_count => temp7_rd_data_count
     );
     
fifo_in_8: fifo
    PORT MAP(
       s_axis_aresetn => aresetn,
       s_axis_aclk  => aclk,
       s_axis_tvalid => s_axis_d_tvalid,
       s_axis_tready => s_axis_d_tready,
       s_axis_tdata => s_axis_d_tdata,
       m_axis_tvalid => d_tvalid,
       m_axis_tready => d_tready,
       m_axis_tdata => d_tdata,
       axis_data_count => temp8_data_count,
       axis_wr_data_count => temp8_wr_data_count,
       axis_rd_data_count => temp8_rd_data_count
     );

div: dividerAxi4 
  Port map( 
   aclk => aclk,
   aresetn => rst,
   s_axis_a_tvalid => axis_sum3_tvalid,
   s_axis_a_tready => axis_sum3_tready,
   s_axis_a_tdata => axis_sum3,
   s_axis_b_tvalid => d_tvalid,
   s_axis_b_tready => d_tready,
   s_axis_b_tdata => d_tdata,
   m_axis_quotient_tvalid => result_tvalid,
   m_axis_quotient_tready => result_tready,
   m_axis_quotient_tdata => result_tdata,
   m_axis_remainder_tvalid => r_tvalid,
   m_axis_remainder_tready => r_tready,
   m_axis_remainder_tdata => r_tdata
  );

fifo_out: fifo
    PORT MAP(
       s_axis_aresetn => aresetn,
       s_axis_aclk  => aclk,
       s_axis_tvalid => result_tvalid,
       s_axis_tready => result_tready,
       s_axis_tdata => result_tdata,
       m_axis_tvalid => m_axis_result_tvalid,
       m_axis_tready => m_axis_result_tready,
       m_axis_tdata => m_axis_result_tdata,
       axis_data_count => res_data_count,
       axis_wr_data_count => res_wr_data_count,
       axis_rd_data_count => res_rd_data_count
     );
     
fifo_out2: fifo
         PORT MAP(
            s_axis_aresetn => aresetn,
            s_axis_aclk  => aclk,
            s_axis_tvalid => r_tvalid,
            s_axis_tready => r_tready,
            s_axis_tdata => r_tdata,
            m_axis_tvalid => m_axis_r_tvalid,
            m_axis_tready => m_axis_r_tready,
            m_axis_tdata => m_axis_r_tdata,
            axis_data_count => r_data_count,
            axis_wr_data_count => r_wr_data_count,
            axis_rd_data_count => r_rd_data_count
          );


end Behavioral;
