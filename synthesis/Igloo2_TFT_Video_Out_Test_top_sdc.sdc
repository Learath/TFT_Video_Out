# Written by Synplify Pro version mapact, Build 004R. Synopsys Run ID: sid1416227345 
# Top Level Design Parameters 

# Clocks 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Igloo2_TFT_Video_Out_Test_CCC_0_FCCC|GL0_net_inferred_clock} [get_pins {Igloo2_TFT_Video_Out_Test_0/CCC_0/CCC_INST:GL0}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Igloo2_TFT_Video_Out_Test_HPMS|FIC_2_APB_M_PCLK_inferred_clock} [get_pins {Igloo2_TFT_Video_Out_Test_0/Igloo2_TFT_Video_Out_Test_HPMS_0/MSS_ADLIB_INST:CLK_CONFIG_APB}] 

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 
set Inferred_clkgroup_0 [list Igloo2_TFT_Video_Out_Test_CCC_0_FCCC|GL0_net_inferred_clock]
set Inferred_clkgroup_1 [list Igloo2_TFT_Video_Out_Test_HPMS|FIC_2_APB_M_PCLK_inferred_clock]
set_clock_groups -asynchronous -group $Inferred_clkgroup_0
set_clock_groups -asynchronous -group $Inferred_clkgroup_1


# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 

# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

