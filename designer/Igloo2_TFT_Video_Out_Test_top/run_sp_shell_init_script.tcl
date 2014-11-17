set_device \
    -family  IGLOO2 \
    -die     PA4MGL1000 \
    -package fg484 \
    -speed   -1 \
    -tempr   {COM} \
    -voltr   {COM}
set_def {VOLTAGE} {1.2}
set_def {VCCI_1.2_VOLTR} {COM}
set_def {VCCI_1.5_VOLTR} {COM}
set_def {VCCI_1.8_VOLTR} {COM}
set_def {VCCI_2.5_VOLTR} {COM}
set_def {VCCI_3.3_VOLTR} {COM}
set_def {PLL_SUPPLY} {PLL_SUPPLY_25}
set_def {PA4_URAM_FF_CONFIG} {SUSPEND}
set_def {PA4_SRAM_FF_CONFIG} {SUSPEND}
set_def {PA4_MSS_FF_CLOCK} {RCOSC_1MHZ}
set_netlist -afl {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.afl} -adl {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.adl}
set_placement   {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.loc}
set_routing     {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.seg}
