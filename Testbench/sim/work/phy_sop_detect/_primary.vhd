library verilog;
use verilog.vl_types.all;
entity phy_sop_detect is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_sop_detect_clr: in     vl_logic;
        phy_bmc_decoder_data: in     vl_logic;
        phy_bmc_decoder_data_en: in     vl_logic;
        phy_sop_detect_type: out    vl_logic_vector(2 downto 0);
        phy_sop_detect_type_en: out    vl_logic;
        phy_sop_detect_payload_out: out    vl_logic_vector(3 downto 0);
        phy_sop_detect_payload_out_en: out    vl_logic;
        phy_sop_detect_eop: out    vl_logic;
        phy_sop_detect_payload_error: out    vl_logic;
        phy_sop_detect_timeout: out    vl_logic
    );
end phy_sop_detect;
