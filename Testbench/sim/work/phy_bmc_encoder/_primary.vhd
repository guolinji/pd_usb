library verilog;
use verilog.vl_types.all;
entity phy_bmc_encoder is
    generic(
        TIME_SCALE_FLAG : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_bmc_encoder_data: in     vl_logic_vector(4 downto 0);
        phy_bmc_encoder_data_en: in     vl_logic;
        phy_bmc_encoder_data_preamble: in     vl_logic;
        phy_bmc_encoder_data_done: out    vl_logic;
        phy_bmc_encoder_hold_lowbmc_done: out    vl_logic;
        phy_bmc_encoder_drive_data: out    vl_logic;
        phy_bmc_encoder_drive_en: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TIME_SCALE_FLAG : constant is 1;
end phy_bmc_encoder;
