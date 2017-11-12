library verilog;
use verilog.vl_types.all;
entity phy_control_tx_rx is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_control_tx_rx_select: out    vl_logic;
        phy_control_tx_rx_clr: out    vl_logic;
        pl2phy_tx_packet_en: in     vl_logic;
        pl2phy_tx_packet_type: in     vl_logic_vector(2 downto 0);
        phy2pl_tx_packet_done: out    vl_logic;
        phy2pl_tx_packet_result: out    vl_logic;
        phy_control_tx_packet_en: out    vl_logic;
        phy_control_tx_packet_type: out    vl_logic_vector(2 downto 0);
        phy_control_tx_packet_done: in     vl_logic;
        phy_definition_of_idle_en: out    vl_logic;
        phy_definition_of_idle_done: in     vl_logic;
        phy_definition_of_idle_result: in     vl_logic;
        pl2phy_rx_packet_select: in     vl_logic;
        phy2pl_rx_packet_en: out    vl_logic;
        phy2pl_rx_packet_type: out    vl_logic_vector(2 downto 0);
        phy2pl_rx_packet_done: out    vl_logic;
        phy2pl_rx_packet_result: out    vl_logic_vector(1 downto 0);
        phy2pl_rx_payload: out    vl_logic_vector(7 downto 0);
        phy2pl_rx_payload_en: out    vl_logic;
        phy_control_rx_packet_en: in     vl_logic;
        phy_control_rx_packet_type: in     vl_logic_vector(2 downto 0);
        phy_control_rx_paylaod: in     vl_logic_vector(3 downto 0);
        phy_control_rx_paylaod_en: in     vl_logic;
        phy_control_rx_packet_eop: in     vl_logic;
        phy_control_rx_packet_crc_error: in     vl_logic;
        phy_control_rx_packet_payload_error: in     vl_logic;
        phy_control_rx_packet_timeout: in     vl_logic
    );
end phy_control_tx_rx;
