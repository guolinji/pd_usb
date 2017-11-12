library verilog;
use verilog.vl_types.all;
entity phy_bmc_decoder is
    generic(
        TIME_SCALE_FLAG : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_bmc_decoder_in: in     vl_logic;
        phy_bmc_decoder_clr: in     vl_logic;
        phy_bmc_decoder_dis: in     vl_logic;
        phy_bmc_decoder_out: out    vl_logic;
        phy_bmc_decoder_out_en: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TIME_SCALE_FLAG : constant is 1;
end phy_bmc_decoder;
