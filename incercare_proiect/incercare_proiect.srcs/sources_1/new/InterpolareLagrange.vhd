----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2023 04:20:48 PM
-- Design Name: 
-- Module Name: InterpolareLagrange - Behavioral
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

entity InterpolareLagrange is
 Port ( 
 aclk : in STD_LOGIC;
 aresetn: in STD_LOGIC;
 rst: in std_logic;
 s_axis_x0_tvalid: in std_logic;
 s_axis_x0_tready : out STD_LOGIC;
 s_axis_x0_tdata : in STD_LOGIC_VECTOR(15 DOWNTO 0);
 s_axis_x1_tvalid: in std_logic;
 s_axis_x1_tready : out STD_LOGIC;
 s_axis_x1_tdata : in STD_LOGIC_VECTOR(15 downto 0);
 s_axis_y0_tvalid: in std_logic;
 s_axis_y0_tready : out STD_LOGIC;
 s_axis_y0_tdata : in STD_LOGIC_VECTOR(15 downto 0);
 s_axis_y1_tvalid : in STD_LOGIC;
 s_axis_y1_tready : out STD_LOGIC;
 s_axis_y1_tdata : in STD_LOGIC_VECTOR (15 downto 0);
 s_axis_x_missing_tvalid : in STD_LOGIC;
 s_axis_x_missing_tready : out STD_LOGIC;
 s_axis_x_missing_tdata : in STD_LOGIC_VECTOR (15 downto 0);
 m_axis_y_missing_tvalid : out STD_LOGIC;
 m_axis_y_missing_tready : in STD_LOGIC;
 m_axis_y_missing_tdata : out STD_LOGIC_VECTOR(15 downto 0)
 );
end InterpolareLagrange;

architecture Behavioral of InterpolareLagrange is

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

component multiplication is
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
end component;

component scazator is
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
end component;

component dividerAxi4 is
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

component sumatorNou is
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
end component;

 signal x0_tvalid, x_missing_tvalid: std_logic;
 signal x0_tready, x_missing_tready: STD_LOGIC;
 signal x0_tdata, x_missing_tdata: STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal x1_tvalid: std_logic;
 signal x1_tready : STD_LOGIC;
 signal x1_tdata : STD_LOGIC_VECTOR(15 downto 0);
 signal y0_tvalid: std_logic;
 signal y1_tvalid: std_logic;
 signal y0_tready, y1_tready: STD_LOGIC;
 signal y1_tdata, y0_tdata : STD_LOGIC_VECTOR(15 downto 0);
 signal sub1_tvalid, sub2_tvalid, sub3_tvalid, sub4_tvalid, sum_tvalid, div1_tvalid, div2_tvalid, mul1_tvalid, mul2_tvalid: STD_LOGIC;
 signal sub1_tready, sub2_tready, sub3_tready, sub4_tready, sum_tready, div1_tready, div2_tready, mul1_tready, mul2_tready: STD_LOGIC := '0';
 signal y2_tdata, sub1, sub2, sub3, axis_sub1, axis_sub2, axis_sub3, sub4, axis_sub4, sum, axis_sum, div1, div2, axis_div1, axis_div2, mul1, mul2, axis_mul1, axis_mul2 : STD_LOGIC_VECTOR (15 downto 0);
 signal y_missing_tvalid: STD_LOGIC;
 signal y_missing_tready: STD_LOGIC;
 signal y_missing_tdata: STD_LOGIC_VECTOR(15 downto 0);
 signal axis_sub1_tvalid, axis_sub2_tvalid, axis_sub3_tvalid, axis_sub4_tready, axis_sum_tready: STD_LOGIC;
 signal axis_sub1_tready, axis_sub2_tready, axis_sub3_tready, axis_sub4_tvalid, axis_sun_tvalid : STD_LOGIC;
 signal axis_div1_tvalid, axis_div2_tvalid, axis_mul1_tvalid, axis_mul2_tready: STD_LOGIC;
 signal axis_div1_tready, axis_div2_tready, axis_mul1_tready, axis_mul2_tvalid: STD_LOGIC;
 signal temp1_data_count, temp2_data_count, temp3_data_count, temp4_data_count, res_data_count, r_data_count : STD_LOGIC_VECTOR (31 downto 0);
 signal temp1_wr_data_count, temp2_wr_data_count, temp3_wr_data_count, temp4_wr_data_count, res_wr_data_count, r_wr_data_count : STD_LOGIC_VECTOR (31 downto 0);
 signal temp1_rd_data_count, temp2_rd_data_count, temp3_rd_data_count, temp4_rd_data_count, res_rd_data_count, r_rd_data_count : STD_LOGIC_VECTOR (31 downto 0);
 signal temp5_wr_data_count, temp6_wr_data_count, temp7_wr_data_count, temp8_wr_data_count, temp9_wr_data_count, temp10_wr_data_count: std_logic_vector (31 downto 0);
 signal temp5_rd_data_count, temp6_rd_data_count, temp7_rd_data_count, temp8_rd_data_count, temp9_rd_data_count, temp10_rd_data_count: std_logic_vector (31 downto 0);
 signal temp5_data_count, temp6_data_count, temp7_data_count, temp8_data_count, temp9_data_count, temp10_data_count: std_logic_vector (31 downto 0);
 signal r1_tready, r1_tvalid, r2_tready, r2_tvalid, axis_result_tvalid, axis_result_tready: std_logic;
 signal r1_tdata, r2_tdata, axis_result_tdata: std_logic_vector(15 downto 0);
 signal temp11_wr_data_count, temp12_wr_data_count, temp13_wr_data_count, temp14_wr_data_count: std_logic_vector (31 downto 0);
 signal temp11_rd_data_count, temp12_rd_data_count, temp13_rd_data_count, temp14_rd_data_count: std_logic_vector (31 downto 0);
 signal temp11_data_count, temp12_data_count, temp13_data_count, temp14_data_count: std_logic_vector (31 downto 0);

begin

fif0_in_1: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => s_axis_x0_tvalid,
    s_axis_tready => s_axis_x0_tready,
    s_axis_tdata => s_axis_x0_tdata,
    m_axis_tvalid => x0_tvalid,
    m_axis_tready => x0_tready,
    m_axis_tdata => x0_tdata,
    axis_data_count => temp1_data_count,
    axis_wr_data_count => temp1_wr_data_count,
    axis_rd_data_count => temp1_rd_data_count
);
  
fifo_in_2: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_x1_tvalid,
      s_axis_tready => s_axis_x1_tready,
      s_axis_tdata => s_axis_x1_tdata,
      m_axis_tvalid => x1_tvalid,
      m_axis_tready => x1_tready,
      m_axis_tdata => x1_tdata,
      axis_data_count => temp2_data_count,
      axis_wr_data_count => temp2_wr_data_count,
      axis_rd_data_count => temp2_rd_data_count
    );
fifo_in_3: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_y0_tvalid,
      s_axis_tready => s_axis_y0_tready,
      s_axis_tdata => s_axis_y0_tdata,
      m_axis_tvalid => y0_tvalid,
      m_axis_tready => y0_tready,
      m_axis_tdata => y0_tdata,
      axis_data_count => temp3_data_count,
      axis_wr_data_count => temp3_wr_data_count,
      axis_rd_data_count => temp3_rd_data_count
  );
  
fif0_in_4: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_y1_tvalid,
      s_axis_tready => s_axis_y1_tready,
      s_axis_tdata => s_axis_y1_tdata,
      m_axis_tvalid => y1_tvalid,
      m_axis_tready => y1_tready,
      m_axis_tdata => y1_tdata,
      axis_data_count => temp4_data_count,
      axis_wr_data_count => temp4_wr_data_count,
      axis_rd_data_count => temp4_rd_data_count
     );
fif0_in_5: fifo
    PORT MAP(
      s_axis_aresetn => aresetn,
      s_axis_aclk  => aclk,
      s_axis_tvalid => s_axis_x_missing_tvalid,
      s_axis_tready => s_axis_x_missing_tready,
      s_axis_tdata => s_axis_x_missing_tdata,
      m_axis_tvalid => x_missing_tvalid,
      m_axis_tready => x_missing_tready,
      m_axis_tdata => x_missing_tdata,
      axis_data_count => temp5_data_count,
      axis_wr_data_count => temp5_wr_data_count,
      axis_rd_data_count => temp5_rd_data_count
    );
    
sca1: scazator
Port Map (
    rst => rst,
    s_axis_X_tvalid => x_missing_tvalid,
    s_axis_X_tready => x_missing_tready,
    s_axis_X_tdata => x_missing_tdata,
    s_axis_Y_tvalid => x1_tvalid,
    s_axis_Y_tready => x1_tready,
    s_axis_Y_tdata => x1_tdata,
    m_axis_S_tvalid => sub1_tvalid,
    m_axis_S_tready => sub1_tready,
    m_axis_S_tdata => sub1
);

sca2: scazator
Port Map (
    rst => rst,
    s_axis_X_tvalid => x_missing_tvalid,
    s_axis_X_tready => x_missing_tready,
    s_axis_X_tdata => x_missing_tdata,
    s_axis_Y_tvalid => x0_tvalid,
    s_axis_Y_tready => x0_tready,
    s_axis_Y_tdata => x0_tdata,
    m_axis_S_tvalid => sub2_tvalid,
    m_axis_S_tready => sub2_tready,
    m_axis_S_tdata => sub2
);

sca3: scazator
Port Map (
    rst => rst,
    s_axis_X_tvalid => x0_tvalid,
    s_axis_X_tready => x0_tready,
    s_axis_X_tdata => x0_tdata,
    s_axis_Y_tvalid => x1_tvalid,
    s_axis_Y_tready => x1_tready,
    s_axis_Y_tdata => x1_tdata,
    m_axis_S_tvalid => sub3_tvalid,
    m_axis_S_tready => sub3_tready,
    m_axis_S_tdata => sub3
);

sca4: scazator
Port Map (
    rst => rst,
    s_axis_X_tvalid => x1_tvalid,
    s_axis_X_tready => x1_tready,
    s_axis_X_tdata => x1_tdata,
    s_axis_Y_tvalid => x0_tvalid,
    s_axis_Y_tready => x0_tready,
    s_axis_Y_tdata => x0_tdata,
    m_axis_S_tvalid => sub4_tvalid,
    m_axis_S_tready => sub4_tready,
    m_axis_S_tdata => sub4
);

fifo6: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => sub1_tvalid,
    s_axis_tready => sub1_tready,
    s_axis_tdata => sub1,
    m_axis_tvalid => axis_sub1_tvalid,
    m_axis_tready => axis_sub1_tready,
    m_axis_tdata => axis_sub1,
    axis_data_count => temp6_data_count,
    axis_wr_data_count => temp6_wr_data_count,
    axis_rd_data_count => temp6_rd_data_count
);

fifo7: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => sub2_tvalid,
    s_axis_tready => sub2_tready,
    s_axis_tdata => sub2,
    m_axis_tvalid => axis_sub2_tvalid,
    m_axis_tready => axis_sub2_tready,
    m_axis_tdata => axis_sub2,
    axis_data_count => temp7_data_count,
    axis_wr_data_count => temp7_wr_data_count,
    axis_rd_data_count => temp7_rd_data_count
);

fifo8: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => sub3_tvalid,
    s_axis_tready => sub3_tready,
    s_axis_tdata => sub3,
    m_axis_tvalid => axis_sub3_tvalid,
    m_axis_tready => axis_sub3_tready,
    m_axis_tdata => axis_sub3,
    axis_data_count => temp8_data_count,
    axis_wr_data_count => temp8_wr_data_count,
    axis_rd_data_count => temp8_rd_data_count
);

fifo9: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => sub4_tvalid,
    s_axis_tready => sub4_tready,
    s_axis_tdata => sub4,
    m_axis_tvalid => axis_sub4_tvalid,
    m_axis_tready => axis_sub4_tready,
    m_axis_tdata => axis_sub4,
    axis_data_count => temp9_data_count,
    axis_wr_data_count => temp9_wr_data_count,
    axis_rd_data_count => temp9_rd_data_count
);

divi1: dividerAxi4 
Port Map (
    aclk => aclk,
    aresetn => rst,
    s_axis_a_tvalid => axis_mul1_tvalid,
    s_axis_a_tready => axis_mul1_tready,
    s_axis_a_tdata => axis_mul1,
    s_axis_b_tvalid => axis_sub3_tvalid,
    s_axis_b_tready => axis_sub3_tready,
    s_axis_b_tdata => axis_sub3,
    m_axis_quotient_tvalid => div1_tvalid,
    m_axis_quotient_tready => div1_tready,
    m_axis_quotient_tdata => div1,
    m_axis_remainder_tvalid => r1_tvalid,
    m_axis_remainder_tready => r1_tready,
    m_axis_remainder_tdata => r1_tdata
);

divi2: dividerAxi4 
Port Map (
    aclk => aclk,
    aresetn => rst,
    s_axis_a_tvalid => axis_mul2_tvalid,
    s_axis_a_tready => axis_mul2_tready,
    s_axis_a_tdata => axis_mul2,
    s_axis_b_tvalid => axis_sub4_tvalid,
    s_axis_b_tready => axis_sub4_tready,
    s_axis_b_tdata => axis_sub4,
    m_axis_quotient_tvalid => div2_tvalid,
    m_axis_quotient_tready => div2_tready,
    m_axis_quotient_tdata => div2,
    m_axis_remainder_tvalid => r2_tvalid,
    m_axis_remainder_tready => r2_tready,
    m_axis_remainder_tdata => r2_tdata
);

fifo10: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => div1_tvalid,
    s_axis_tready => div1_tready,
    s_axis_tdata => div1,
    m_axis_tvalid => axis_div1_tvalid,
    m_axis_tready => axis_div1_tready,
    m_axis_tdata => axis_div1,
    axis_data_count => temp10_data_count,
    axis_wr_data_count => temp10_wr_data_count,
    axis_rd_data_count => temp10_rd_data_count
);

fifo11: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => div2_tvalid,
    s_axis_tready => div2_tready,
    s_axis_tdata => div2,
    m_axis_tvalid => axis_div2_tvalid,
    m_axis_tready => axis_div2_tready,
    m_axis_tdata => axis_div2,
    axis_data_count => temp11_data_count,
    axis_wr_data_count => temp11_wr_data_count,
    axis_rd_data_count => temp11_rd_data_count
);

mult1: multiplication
Port Map (
Clk => aclk,
Rst => rst,
s_axis_a_tvalid => axis_sub1_tvalid,
s_axis_a_tready => axis_sub1_tready,
s_axis_a_tdata => axis_sub1,
s_axis_b_tvalid => y0_tvalid,
s_axis_b_tready => y0_tready,
s_axis_b_tdata => y0_tdata,
m_axis_res_tvalid => mul1_tvalid,
m_axis_res_tready => mul1_tready,
m_axis_res_tdata => mul1
);

mult2: multiplication
Port Map (
Clk => aclk,
Rst => rst,
s_axis_a_tvalid => axis_sub2_tvalid,
s_axis_a_tready => axis_sub2_tready,
s_axis_a_tdata => axis_sub2,
s_axis_b_tvalid => y1_tvalid,
s_axis_b_tready => y1_tready,
s_axis_b_tdata => y1_tdata,
m_axis_res_tvalid => mul2_tvalid,
m_axis_res_tready => mul2_tready,
m_axis_res_tdata => mul2
);

fifo12: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => mul1_tvalid,
    s_axis_tready => mul1_tready,
    s_axis_tdata => mul1,
    m_axis_tvalid => axis_mul1_tvalid,
    m_axis_tready => axis_mul1_tready,
    m_axis_tdata => axis_mul1,
    axis_data_count => temp12_data_count,
    axis_wr_data_count => temp12_wr_data_count,
    axis_rd_data_count => temp12_rd_data_count
);

fifo13: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => mul2_tvalid,
    s_axis_tready => mul2_tready,
    s_axis_tdata => mul2,
    m_axis_tvalid => axis_mul2_tvalid,
    m_axis_tready => axis_mul2_tready,
    m_axis_tdata => axis_mul2,
    axis_data_count => temp13_data_count,
    axis_wr_data_count => temp13_wr_data_count,
    axis_rd_data_count => temp13_rd_data_count
);

adder1: sumatorNou
Port map(
    rst => rst,
    s_axis_X_tvalid => axis_div1_tvalid,
    s_axis_X_tready => axis_div1_tready,
    s_axis_X_tdata => axis_div1,
    s_axis_Y_tvalid => axis_div2_tvalid,
    s_axis_Y_tready => axis_div2_tready,
    s_axis_Y_tdata => axis_div2,
    m_axis_S_tvalid => axis_result_tvalid,
    m_axis_S_tready => axis_result_tready,
    m_axis_S_tdata => axis_result_tdata
);

fifo_out: fifo
PORT MAP(
    s_axis_aresetn => aresetn,
    s_axis_aclk  => aclk,
    s_axis_tvalid => axis_result_tvalid,
    s_axis_tready => axis_result_tready,
    s_axis_tdata => axis_result_tdata,
    m_axis_tvalid => m_axis_y_missing_tvalid,
    m_axis_tready => m_axis_y_missing_tready,
    m_axis_tdata => m_axis_y_missing_tdata,
    axis_data_count => res_data_count,
    axis_wr_data_count => res_wr_data_count,
    axis_rd_data_count => res_rd_data_count
);


end Behavioral;
