-makelib ies/xil_defaultlib -sv \
  "D:/Vivado/2016.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Vivado/2016.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "D:/Vivado/2016.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/axis_infrastructure_v1_1_0 \
  "../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies/fifo_generator_v13_1_3 \
  "../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies/fifo_generator_v13_1_3 \
  "../../../ipstatic/hdl/fifo_generator_v13_1_rfs.vhd" \
-endlib
-makelib ies/fifo_generator_v13_1_3 \
  "../../../ipstatic/hdl/fifo_generator_v13_1_rfs.v" \
-endlib
-makelib ies/axis_data_fifo_v1_1_12 \
  "../../../ipstatic/hdl/axis_data_fifo_v1_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../incercare_proiect.srcs/sources_1/ip/fifo/sim/fifo.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

