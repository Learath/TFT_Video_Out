set_device -fam IGLOO2
read_edif  \
    -file {/home/nick/src/Igloo2_TFT_Video_Out_test/synthesis/Igloo2_TFT_Video_Out_Test_top.edn}
write_vhdl -file {/home/nick/src/Igloo2_TFT_Video_Out_test/synthesis/Igloo2_TFT_Video_Out_Test_top.vhd}
