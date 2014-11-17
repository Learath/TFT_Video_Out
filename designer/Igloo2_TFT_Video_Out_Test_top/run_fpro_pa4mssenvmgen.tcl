set_device \
    -fam IGLOO2 \
    -die PA4MGL1000 \
    -pkg fg484
set_mddr_reg \
	-path {/home/nick/src/Igloo2_TFT_Video_Out_test/component/work/Igloo2_TFT_Video_Out_Test_HPMS/MDDR_init.reg}
set_output_efc \
    -path {/home/nick/src/Igloo2_TFT_Video_Out_test/designer/Igloo2_TFT_Video_Out_Test_top/Igloo2_TFT_Video_Out_Test_top.efc}
gen_prg -use_init true
