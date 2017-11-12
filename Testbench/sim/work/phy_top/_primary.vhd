library verilog;
use verilog.vl_types.all;
entity phy_top is
    generic(
        TIME_SCALE_FLAG : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pl2phy_tx_bist_carrier_mode: in     vl_logic;
        pl2phy_tx_packet_en: in     vl_logic;
        pl2phy_tx_packet_type: in     vl_logic_vector(2 downto 0);
        phy2pl_tx_packet_done: out    vl_logic;
        phy2pl_tx_packet_result: out    vl_logic;
        pl2phy_rx_packet_select: in     vl_logic;
        phy2pl_rx_packet_en: out    vl_logic;
        phy2pl_rx_packet_type: out    vl_logic_vector(2 downto 0);
        phy2pl_rx_packet_done: out    vl_logic;
        phy2pl_rx_packet_result: out    vl_logic_vector(1 downto 0);
        pl2phy_tx_payload_en: in     vl_logic;
        pl2phy_tx_payload: in     vl_logic_vector(7 downto 0);
        pl2phy_tx_payload_last: in     vl_logic;
        phy2pl_tx_payload_done: out    vl_logic;
        phy2pl_rx_payload: out    vl_logic_vector(7 downto 0);
        phy2pl_rx_payload_en: out    vl_logic;
        pl2phy_reset_req: in     vl_logic;
        phy2pl_tx_phy_reset_done: out    vl_logic;
        pl2phy_tx_phy_reset_req: in     vl_logic;
        phy_cc_signal   : inout  vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TIME_SCALE_FLAG : constant is 1;
end phy_top;
