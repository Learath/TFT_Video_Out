----------------------------------------------------------------------
-- Created by SmartDesign Thu Oct 30 00:45:53 2014
-- Version: v11.4 11.4.0.112
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- Igloo2_TFT_Video_Out_Test_top entity declaration
----------------------------------------------------------------------
entity Igloo2_TFT_Video_Out_Test_top is
    -- Port list
    port(
        -- Inputs
        DEVRST_N              : in    std_logic;
        MDDR_DQS_TMATCH_0_IN  : in    std_logic;
        SWITCH                : in    std_logic;
        -- Outputs
        MDDR_ADDR             : out   std_logic_vector(15 downto 0);
        MDDR_BA               : out   std_logic_vector(2 downto 0);
        MDDR_CAS_N            : out   std_logic;
        MDDR_CKE              : out   std_logic;
        MDDR_CLK              : out   std_logic;
        MDDR_CLK_N            : out   std_logic;
        MDDR_CS_N             : out   std_logic;
        MDDR_DQS_TMATCH_0_OUT : out   std_logic;
        MDDR_ODT              : out   std_logic;
        MDDR_RAS_N            : out   std_logic;
        MDDR_RESET_N          : out   std_logic;
        MDDR_WE_N             : out   std_logic;
        PIXEL_o               : out   std_logic_vector(7 downto 0);
        -- Inouts
        MDDR_DM_RDQS          : inout std_logic_vector(1 downto 0);
        MDDR_DQ               : inout std_logic_vector(15 downto 0);
        MDDR_DQS              : inout std_logic_vector(1 downto 0)
        );
end Igloo2_TFT_Video_Out_Test_top;
----------------------------------------------------------------------
-- Igloo2_TFT_Video_Out_Test_top architecture body
----------------------------------------------------------------------
architecture RTL of Igloo2_TFT_Video_Out_Test_top is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- DEBOUNCE
component DEBOUNCE
    -- Port list
    port(
        -- Inputs
        CLK       : in  std_logic;
        RESET_N   : in  std_logic;
        SWITCH    : in  std_logic;
        -- Outputs
        INTERRUPT : out std_logic
        );
end component;
-- Igloo2_TFT_Video_Out_Test
component Igloo2_TFT_Video_Out_Test
    -- Port list
    port(
        -- Inputs
        AMBA_MASTER_0_HADDR_M0      : in    std_logic_vector(31 downto 0);
        AMBA_MASTER_0_HBURST_M0     : in    std_logic_vector(2 downto 0);
        AMBA_MASTER_0_HMASTLOCK_M0  : in    std_logic;
        AMBA_MASTER_0_HPROT_M0      : in    std_logic_vector(3 downto 0);
        AMBA_MASTER_0_HSIZE_M0      : in    std_logic_vector(2 downto 0);
        AMBA_MASTER_0_HTRANS_M0     : in    std_logic_vector(1 downto 0);
        AMBA_MASTER_0_HWDATA_M0     : in    std_logic_vector(31 downto 0);
        AMBA_MASTER_0_HWRITE_M0     : in    std_logic;
        DEVRST_N                    : in    std_logic;
        FAB_RESET_N                 : in    std_logic;
        MDDR_DQS_TMATCH_0_IN        : in    std_logic;
        -- Outputs
        AMBA_MASTER_0_HRDATA_M0     : out   std_logic_vector(31 downto 0);
        AMBA_MASTER_0_HREADY_M0     : out   std_logic;
        AMBA_MASTER_0_HRESP_M0      : out   std_logic_vector(1 downto 0);
        COMM_BLK_INT                : out   std_logic;
        DDR_READY                   : out   std_logic;
        FAB_CCC_GL0                 : out   std_logic;
        HPMS_DDR_FIC_SUBSYSTEM_CLK  : out   std_logic;
        HPMS_DDR_FIC_SUBSYSTEM_LOCK : out   std_logic;
        HPMS_INT_M2F                : out   std_logic_vector(15 downto 0);
        HPMS_READY                  : out   std_logic;
        INIT_DONE                   : out   std_logic;
        MDDR_ADDR                   : out   std_logic_vector(15 downto 0);
        MDDR_BA                     : out   std_logic_vector(2 downto 0);
        MDDR_CAS_N                  : out   std_logic;
        MDDR_CKE                    : out   std_logic;
        MDDR_CLK                    : out   std_logic;
        MDDR_CLK_N                  : out   std_logic;
        MDDR_CS_N                   : out   std_logic;
        MDDR_DQS_TMATCH_0_OUT       : out   std_logic;
        MDDR_ODT                    : out   std_logic;
        MDDR_RAS_N                  : out   std_logic;
        MDDR_RESET_N                : out   std_logic;
        MDDR_WE_N                   : out   std_logic;
        POWER_ON_RESET_N            : out   std_logic;
        -- Inouts
        MDDR_DM_RDQS                : inout std_logic_vector(1 downto 0);
        MDDR_DQ                     : inout std_logic_vector(15 downto 0);
        MDDR_DQS                    : inout std_logic_vector(1 downto 0)
        );
end component;
-- patternGen
component patternGen
    -- Port list
    port(
        -- Inputs
        CLK_i      : in  std_logic;
        CLKen_i    : in  std_logic;
        RST_i      : in  std_logic;
        SEL_i      : in  std_logic_vector(2 downto 0);
        -- Outputs
        ENDframe_o : out std_logic;
        ENDline_o  : out std_logic;
        PIXEL_o    : out std_logic_vector(7 downto 0);
        VALID_o    : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal DEBOUNCE_0_INTERRUPT                    : std_logic;
signal Igloo2_TFT_Video_Out_Test_0_FAB_CCC_GL0 : std_logic;
signal MDDR_ADDR_net_0                         : std_logic_vector(15 downto 0);
signal MDDR_BA_net_0                           : std_logic_vector(2 downto 0);
signal MDDR_CAS_N_net_0                        : std_logic;
signal MDDR_CKE_net_0                          : std_logic;
signal MDDR_CLK_net_0                          : std_logic;
signal MDDR_CLK_N_net_0                        : std_logic;
signal MDDR_CS_N_net_0                         : std_logic;
signal MDDR_DQS_TMATCH_0_OUT_net_0             : std_logic;
signal MDDR_ODT_net_0                          : std_logic;
signal MDDR_RAS_N_net_0                        : std_logic;
signal MDDR_RESET_N_net_0                      : std_logic;
signal MDDR_WE_N_net_0                         : std_logic;
signal PIXEL_o_net_0                           : std_logic_vector(7 downto 0);
signal MDDR_DQS_TMATCH_0_OUT_net_1             : std_logic;
signal MDDR_CAS_N_net_1                        : std_logic;
signal MDDR_CLK_net_1                          : std_logic;
signal MDDR_CLK_N_net_1                        : std_logic;
signal MDDR_CKE_net_1                          : std_logic;
signal MDDR_CS_N_net_1                         : std_logic;
signal MDDR_ODT_net_1                          : std_logic;
signal MDDR_RAS_N_net_1                        : std_logic;
signal MDDR_RESET_N_net_1                      : std_logic;
signal MDDR_WE_N_net_1                         : std_logic;
signal MDDR_ADDR_net_1                         : std_logic_vector(15 downto 0);
signal MDDR_BA_net_1                           : std_logic_vector(2 downto 0);
signal PIXEL_o_net_1                           : std_logic_vector(7 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net                                 : std_logic;
signal SEL_i_const_net_0                       : std_logic_vector(2 downto 0);
signal AMBA_MASTER_0_HADDR_M0_const_net_0      : std_logic_vector(31 downto 0);
signal AMBA_MASTER_0_HTRANS_M0_const_net_0     : std_logic_vector(1 downto 0);
signal GND_net                                 : std_logic;
signal AMBA_MASTER_0_HSIZE_M0_const_net_0      : std_logic_vector(2 downto 0);
signal AMBA_MASTER_0_HBURST_M0_const_net_0     : std_logic_vector(2 downto 0);
signal AMBA_MASTER_0_HPROT_M0_const_net_0      : std_logic_vector(3 downto 0);
signal AMBA_MASTER_0_HWDATA_M0_const_net_0     : std_logic_vector(31 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net                             <= '1';
 SEL_i_const_net_0                   <= B"000";
 AMBA_MASTER_0_HADDR_M0_const_net_0  <= B"00000000000000000000000000000000";
 AMBA_MASTER_0_HTRANS_M0_const_net_0 <= B"00";
 GND_net                             <= '0';
 AMBA_MASTER_0_HSIZE_M0_const_net_0  <= B"000";
 AMBA_MASTER_0_HBURST_M0_const_net_0 <= B"000";
 AMBA_MASTER_0_HPROT_M0_const_net_0  <= B"0000";
 AMBA_MASTER_0_HWDATA_M0_const_net_0 <= B"00000000000000000000000000000000";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 MDDR_DQS_TMATCH_0_OUT_net_1 <= MDDR_DQS_TMATCH_0_OUT_net_0;
 MDDR_DQS_TMATCH_0_OUT       <= MDDR_DQS_TMATCH_0_OUT_net_1;
 MDDR_CAS_N_net_1            <= MDDR_CAS_N_net_0;
 MDDR_CAS_N                  <= MDDR_CAS_N_net_1;
 MDDR_CLK_net_1              <= MDDR_CLK_net_0;
 MDDR_CLK                    <= MDDR_CLK_net_1;
 MDDR_CLK_N_net_1            <= MDDR_CLK_N_net_0;
 MDDR_CLK_N                  <= MDDR_CLK_N_net_1;
 MDDR_CKE_net_1              <= MDDR_CKE_net_0;
 MDDR_CKE                    <= MDDR_CKE_net_1;
 MDDR_CS_N_net_1             <= MDDR_CS_N_net_0;
 MDDR_CS_N                   <= MDDR_CS_N_net_1;
 MDDR_ODT_net_1              <= MDDR_ODT_net_0;
 MDDR_ODT                    <= MDDR_ODT_net_1;
 MDDR_RAS_N_net_1            <= MDDR_RAS_N_net_0;
 MDDR_RAS_N                  <= MDDR_RAS_N_net_1;
 MDDR_RESET_N_net_1          <= MDDR_RESET_N_net_0;
 MDDR_RESET_N                <= MDDR_RESET_N_net_1;
 MDDR_WE_N_net_1             <= MDDR_WE_N_net_0;
 MDDR_WE_N                   <= MDDR_WE_N_net_1;
 MDDR_ADDR_net_1             <= MDDR_ADDR_net_0;
 MDDR_ADDR(15 downto 0)      <= MDDR_ADDR_net_1;
 MDDR_BA_net_1               <= MDDR_BA_net_0;
 MDDR_BA(2 downto 0)         <= MDDR_BA_net_1;
 PIXEL_o_net_1               <= PIXEL_o_net_0;
 PIXEL_o(7 downto 0)         <= PIXEL_o_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- DEBOUNCE_0
DEBOUNCE_0 : DEBOUNCE
    port map( 
        -- Inputs
        CLK       => Igloo2_TFT_Video_Out_Test_0_FAB_CCC_GL0,
        RESET_N   => VCC_net,
        SWITCH    => SWITCH,
        -- Outputs
        INTERRUPT => DEBOUNCE_0_INTERRUPT 
        );
-- Igloo2_TFT_Video_Out_Test_0
Igloo2_TFT_Video_Out_Test_0 : Igloo2_TFT_Video_Out_Test
    port map( 
        -- Inputs
        MDDR_DQS_TMATCH_0_IN        => MDDR_DQS_TMATCH_0_IN,
        FAB_RESET_N                 => VCC_net,
        AMBA_MASTER_0_HADDR_M0      => AMBA_MASTER_0_HADDR_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HTRANS_M0     => AMBA_MASTER_0_HTRANS_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HWRITE_M0     => GND_net, -- tied to '0' from definition
        AMBA_MASTER_0_HSIZE_M0      => AMBA_MASTER_0_HSIZE_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HBURST_M0     => AMBA_MASTER_0_HBURST_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HPROT_M0      => AMBA_MASTER_0_HPROT_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HWDATA_M0     => AMBA_MASTER_0_HWDATA_M0_const_net_0, -- tied to X"0" from definition
        AMBA_MASTER_0_HMASTLOCK_M0  => GND_net, -- tied to '0' from definition
        DEVRST_N                    => DEVRST_N,
        -- Outputs
        MDDR_DQS_TMATCH_0_OUT       => MDDR_DQS_TMATCH_0_OUT_net_0,
        MDDR_CAS_N                  => MDDR_CAS_N_net_0,
        MDDR_CLK                    => MDDR_CLK_net_0,
        MDDR_CLK_N                  => MDDR_CLK_N_net_0,
        MDDR_CKE                    => MDDR_CKE_net_0,
        MDDR_CS_N                   => MDDR_CS_N_net_0,
        MDDR_ODT                    => MDDR_ODT_net_0,
        MDDR_RAS_N                  => MDDR_RAS_N_net_0,
        MDDR_RESET_N                => MDDR_RESET_N_net_0,
        MDDR_WE_N                   => MDDR_WE_N_net_0,
        MDDR_ADDR                   => MDDR_ADDR_net_0,
        MDDR_BA                     => MDDR_BA_net_0,
        POWER_ON_RESET_N            => OPEN,
        INIT_DONE                   => OPEN,
        AMBA_MASTER_0_HRDATA_M0     => OPEN,
        AMBA_MASTER_0_HREADY_M0     => OPEN,
        AMBA_MASTER_0_HRESP_M0      => OPEN,
        HPMS_DDR_FIC_SUBSYSTEM_CLK  => OPEN,
        HPMS_DDR_FIC_SUBSYSTEM_LOCK => OPEN,
        DDR_READY                   => OPEN,
        FAB_CCC_GL0                 => Igloo2_TFT_Video_Out_Test_0_FAB_CCC_GL0,
        HPMS_READY                  => OPEN,
        COMM_BLK_INT                => OPEN,
        HPMS_INT_M2F                => OPEN,
        -- Inouts
        MDDR_DM_RDQS                => MDDR_DM_RDQS,
        MDDR_DQ                     => MDDR_DQ,
        MDDR_DQS                    => MDDR_DQS 
        );
-- patternGen_0
patternGen_0 : patternGen
    port map( 
        -- Inputs
        CLK_i      => Igloo2_TFT_Video_Out_Test_0_FAB_CCC_GL0,
        RST_i      => DEBOUNCE_0_INTERRUPT,
        SEL_i      => SEL_i_const_net_0,
        CLKen_i    => VCC_net,
        -- Outputs
        VALID_o    => OPEN,
        ENDline_o  => OPEN,
        ENDframe_o => OPEN,
        PIXEL_o    => PIXEL_o_net_0 
        );

end RTL;
