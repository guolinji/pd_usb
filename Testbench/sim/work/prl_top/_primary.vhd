library verilog;
use verilog.vl_types.all;
entity prl_top is
    generic(
        TIME_SCALE_FLAG : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pe2pl_tx_en     : in     vl_logic;
        pe2pl_tx_type   : in     vl_logic_vector(6 downto 0);
        pe2pl_tx_sop_type: in     vl_logic_vector(2 downto 0);
        pe2pl_tx_info   : in     vl_logic_vector(4 downto 0);
        pe2pl_tx_ex_info: in     vl_logic_vector(35 downto 0);
        pl2pe_tx_ack    : out    vl_logic;
        pl2pe_tx_result : out    vl_logic_vector(1 downto 0);
        pe2pl_tx_ams_begin: in     vl_logic;
        pe2pl_tx_ams_end: in     vl_logic;
        pe2pl_tx_bist_carrier_mode: in     vl_logic;
        pl2pe_rx_en     : out    vl_logic;
        pl2pe_rx_type   : out    vl_logic_vector(6 downto 0);
        pl2pe_rx_sop_type: out    vl_logic_vector(2 downto 0);
        pl2pe_rx_info   : out    vl_logic_vector(22 downto 0);
        pl2pe_hard_reset_req: out    vl_logic;
        pe2pl_hard_reset_ack: in     vl_logic;
        prl2phy_tx_packet_en: out    vl_logic;
        prl2phy_tx_packet_type: out    vl_logic_vector(2 downto 0);
        phy2prl_tx_packet_done: in     vl_logic;
        phy2prl_tx_packet_result: in     vl_logic;
        prl2phy_tx_payload_en: out    vl_logic;
        prl2phy_tx_payload: out    vl_logic_vector(7 downto 0);
        prl2phy_tx_payload_last: out    vl_logic;
        phy2prl_tx_payload_done: in     vl_logic;
        phy2prl_tx_phy_reset_done: in     vl_logic;
        prl2phy_tx_phy_reset_req: out    vl_logic;
        pe2pl_reset_req : in     vl_logic;
        prl2phy_reset_req: out    vl_logic;
        prl2phy_tx_bist_carrier_mode: out    vl_logic;
        prl2phy_rx_packet_select: out    vl_logic;
        phy2prl_rx_packet_en: in     vl_logic;
        phy2prl_rx_packet_type: in     vl_logic_vector(2 downto 0);
        phy2prl_rx_packet_done: in     vl_logic;
        phy2prl_rx_packet_result: in     vl_logic_vector(1 downto 0);
        phy2prl_rx_payload: in     vl_logic_vector(7 downto 0);
        phy2prl_rx_payload_req: in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TIME_SCALE_FLAG : constant is 1;
end prl_top;
