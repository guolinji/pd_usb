library verilog;
use verilog.vl_types.all;
entity prl_ctl_state_machine is
    generic(
        TIME_SCALE_FLAG : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pe2pl_tx_ams_begin: in     vl_logic;
        pe2pl_tx_ams_end: in     vl_logic;
        pe2pl_tx_bist_carrier_mode: in     vl_logic;
        prl2phy_tx_phy_reset_req: out    vl_logic;
        phy2prl_tx_phy_reset_done: in     vl_logic;
        prl2phy_rx_packet_select: out    vl_logic;
        prl2phy_tx_bist_carrier_mode: out    vl_logic;
        pl2pe_hard_reset_req: out    vl_logic;
        pe2pl_hard_reset_ack: in     vl_logic;
        prl_rx_st_inform_pe_en: out    vl_logic;
        prl_rx_parser_message_req: in     vl_logic;
        prl_rx_parser_message_type: in     vl_logic_vector(1 downto 0);
        prl_rx_parser_sop_type: in     vl_logic_vector(2 downto 0);
        prl_rx_parser_header_type: in     vl_logic_vector(4 downto 0);
        prl_rx_parser_message_id: in     vl_logic_vector(2 downto 0);
        prl_tx_st_message_construct_reset: out    vl_logic;
        prl_tx_st_message_construct_req: out    vl_logic;
        prl_tx_st_messageid_counter: out    vl_logic_vector(2 downto 0);
        prl_tx_st_message_construct_ack: in     vl_logic;
        prl_tx_st_message_construct_ack_result: in     vl_logic;
        prl_tx_st_message_if_ack: out    vl_logic;
        prl_tx_st_message_if_ack_result: out    vl_logic_vector(1 downto 0);
        prl_tx_if_en    : in     vl_logic;
        prl_tx_if_sop_type: in     vl_logic_vector(2 downto 0);
        prl_tx_if_message_type: in     vl_logic_vector(1 downto 0);
        prl_tx_if_header_type: in     vl_logic_vector(4 downto 0);
        prl_tx_if_ex_message_data_size: in     vl_logic_vector(8 downto 0);
        prl_rx_st_send_goodcrc_req: out    vl_logic;
        prl_rx_st_send_goodcrc_sop_type: out    vl_logic_vector(1 downto 0);
        prl_rx_st_send_goodcrc_messageid: out    vl_logic_vector(2 downto 0);
        prl_rx_st_send_goodcrc_ack: in     vl_logic;
        prl_rx_st_send_goodcrc_ack_result: in     vl_logic;
        prl_hdrst_send_req: out    vl_logic;
        prl_hdrst_send_ack: in     vl_logic;
        prl_hdrst_send_ack_result: in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TIME_SCALE_FLAG : constant is 1;
end prl_ctl_state_machine;
