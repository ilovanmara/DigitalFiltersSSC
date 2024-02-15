onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+fifo -L xil_defaultlib -L xpm -L axis_infrastructure_v1_1_0 -L fifo_generator_v13_1_3 -L axis_data_fifo_v1_1_12 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {fifo.udo}

run -all

endsim

quit -force
