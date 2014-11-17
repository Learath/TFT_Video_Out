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
set_name Igloo2_TFT_Video_Out_Test_top
set_workdir {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top}
set_design_state pre_layout
