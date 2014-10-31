save
set has_violations {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_pre_layout_has_violations}
set fp [open $has_violations w]
puts $fp [has_violations -short]
close $fp
report -type combinational_loops -format xml {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_combinational_loops.xml}
if { [catch "file delete -force -- {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/pinslacks.txt}"] } {
   ;
}
report -type slack {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/pinslacks.txt}
