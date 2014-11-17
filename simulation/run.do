quietly set ACTELLIBNAME smartfusion2
quietly set PROJECT_DIR "/home/nick/src/Igloo2_TFT_Video_Out_test"
onerror { quit -f }
onbreak { quit -f }
source "${PROJECT_DIR}/simulation/bfmtovec_compile.tcl";

if {[file exists postsynth/_info]} {
   echo "INFO: Simulation library postsynth already exists"
} else {
   file delete -force postsynth 
   vlib postsynth
}
vmap postsynth postsynth
vmap smartfusion2 "/opt/microsemi/Libero_v11.4/Libero/lib/modelsim/precompiled/vhdl/smartfusion2"
vmap SmartFusion2 "/opt/microsemi/Libero_v11.4/Libero/lib/modelsim/precompiled/vhdl/smartfusion2"
vmap COREAHBLITE_LIB "../component/Actel/DirectCore/CoreAHBLite/5.0.100/mti/user_vhdl/COREAHBLITE_LIB"
vcom -work COREAHBLITE_LIB -force_refresh
vlog -work COREAHBLITE_LIB -force_refresh

vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/components.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_addrdec.vhd"
vcom -93 -explicit  -work postsynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreConfigMaster/2.1.102/rtl/vhdl/core/coreconfigmaster.vhd"
vcom -93 -explicit  -work postsynth "${PROJECT_DIR}/synthesis/Igloo2_TFT_Video_Out_Test_top.vhd"

vsim -L smartfusion2 -L postsynth -L COREAHBLITE_LIB  -t 1fs postsynth.Igloo2_TFT_Video_Out_Test_top
# The following lines are commented because no testbench is associated with the project
# add wave /testbench/*
# run 1000ns
# log /testbench/*
exit
