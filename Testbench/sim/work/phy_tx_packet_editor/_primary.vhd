library verilog;
use verilog.vl_types.all;
entity phy_tx_packet_editor is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pl2phy_tx_payload: in     vl_logic_vector(7 downto 0);
        pl2phy_tx_payload_last: in     vl_logic;
        phy2pl_tx_payload_done: out    vl_logic;
        phy_tx_bist_en  : in     vl_logic;
        phy_tx_packet_en: in     vl_logic;
        phy_tx_packet_type: in     vl_logic_vector(2 downto 0);
        phy_tx_packet_crc: in     vl_logic_vector(31 downto 0);
        phy_bmc_encoder_data_en: out    vl_logic;
        phy_bmc_encoder_data: out    vl_logic_vector(4 downto 0);
        phy_bmc_encoder_data_preamble: out    vl_logic;
        phy_bmc_encoder_data_done: in     vl_logic;
        phy_bmc_encoder_hold_lowbmc_done: in     vl_logic
    );
end phy_tx_packet_editor;
