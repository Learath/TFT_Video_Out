report \
    -type     timing \
    -analysis max \
    -format   xml \
    {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_maxdelay_timing_report.xml}
report \
    -type     timing \
    -analysis min \
    -format   xml \
    {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_mindelay_timing_report.xml}
report \
    -type     timing_violations \
    -analysis max \
    -format   xml \
    {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_maxdelay_timing_violations_report.xml}
report \
    -type     timing_violations \
    -analysis min \
    -format   xml \
    {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_mindelay_timing_violations_report.xml}
set has_violations {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top_has_violations}
set fp [open $has_violations w]
puts $fp [has_violations -short]
close $fp
