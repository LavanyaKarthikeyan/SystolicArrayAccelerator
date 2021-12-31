# systolicarray-acc
 
This repository includes the following
 1. Vivado project (sources includes) for an 8x8 systolic array based accelerator which accepts Hoffman encoded weights
 2. Three testcases with different quantization and pruning parameters


For running,
 1. Replace the paths in the testbench with the correct local paths
 2. Use `get_files -filter {FILE_TYPE == Verilog}` on Vivado to get the sources and testbench filelist
