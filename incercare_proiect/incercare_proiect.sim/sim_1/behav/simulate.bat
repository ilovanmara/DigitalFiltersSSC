@echo off
set xv_path=D:\\Vivado\\2016.4\\bin
call %xv_path%/xsim tb_filtruMedie_behav -key {Behavioral:sim_1:Functional:tb_filtruMedie} -tclbatch tb_filtruMedie.tcl -view C:/Users/mara_/Desktop/ssc/incercare_proiect/tb_filtruMedie_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
