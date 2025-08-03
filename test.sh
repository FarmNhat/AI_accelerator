
iverilog -o testPE testPE.v #PE/controller.v 
vvp testPE
gtkwave testPE.vcd