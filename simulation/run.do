quietly set ACTELLIBNAME smartfusion2
quietly set PROJECT_DIR "/home/nick/src/Igloo2_TFT_Video_Out_test"
onerror { quit -f }
onbreak { quit -f }
source "${PROJECT_DIR}/simulation/bfmtovec_compile.tcl";

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap smartfusion2 "/opt/microsemi/Libero_v11.4/Libero/lib/modelsim/precompiled/vhdl/smartfusion2"
vmap SmartFusion2 "/opt/microsemi/Libero_v11.4/Libero/lib/modelsim/precompiled/vhdl/smartfusion2"
vmap COREAHBLITE_LIB "../component/Actel/DirectCore/CoreAHBLite/5.0.100/mti/user_vhdl/COREAHBLITE_LIB"
vcom -work COREAHBLITE_LIB -force_refresh
vlog -work COREAHBLITE_LIB -force_refresh

vcom -93 -explicit  -work presynth "${PROJECT_DIR}/hdl/Debounce.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/work/Igloo2_TFT_Video_Out_Test/CCC_0/Igloo2_TFT_Video_Out_Test_CCC_0_FCCC.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreConfigMaster/2.1.102/rtl/vhdl/core/coreconfigmaster.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreConfigP/7.0.105/rtl/vhdl/core/coreconfigp.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.0.104/rtl/vhdl/core/coreresetp_pcie_hotreset.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.0.104/rtl/vhdl/core/coreresetp.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/work/Igloo2_TFT_Video_Out_Test/FABOSC_0/Igloo2_TFT_Video_Out_Test_FABOSC_0_OSC.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/work/Igloo2_TFT_Video_Out_Test_HPMS/Igloo2_TFT_Video_Out_Test_HPMS.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_addrdec.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_defaultslavesm.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_masterstage.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_slavearbiter.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_slavestage.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite_matrix4x16.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/coreahblite.vhd"
vcom -93 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.0.100/rtl/vhdl/core/components.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/work/Igloo2_TFT_Video_Out_Test/Igloo2_TFT_Video_Out_Test.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/hdl/xcounter.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/hdl/patternGen.vhd"
vcom -93 -explicit  -work presynth "${PROJECT_DIR}/component/work/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.vhd"

vsim -L smartfusion2 -L presynth -L COREAHBLITE_LIB  -t 1fs presynth.Igloo2_TFT_Video_Out_Test_top
# The following lines are commented because no testbench is associated with the project
# add wave /testbench/*
# run 1000ns
# log /testbench/*
exit
