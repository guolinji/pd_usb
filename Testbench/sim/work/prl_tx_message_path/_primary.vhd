library verilog;
use verilog.vl_types.all;
entity prl_tx_message_path is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        prl2phy_tx_packet_en: out    vl_logic;
        prl2phy_tx_packet_type: out    vl_logic_vector(2 downto 0);
        phy2prl_tx_packet_done: in     vl_logic;
        phy2prl_tx_packet_result: in     vl_logic;
        prl2phy_tx_payload_en: out    vl_logic;
        prl2phy_tx_payload: out    vl_logic_vector(7 downto 0);
        prl2phy_tx_payload_last: out    vl_logic;
        phy2prl_tx_payload_done: in     vl_logic;
        prl_tx_if_sop_type: in     vl_logic_vector(2 downto 0);
        prl_tx_if_message_type: in     vl_logic_vector(1 downto 0);
        prl_tx_if_header_type: in     vl_logic_vector(4 downto 0);
        prl_tx_if_source_cap_table_select: in     vl_logic_vector(3 downto 0);
        prl_tx_if_source_cap_current: in     vl_logic;
        prl_tx_if_ex_message_data_size: in     vl_logic_vector(8 downto 0);
        prl_tx_if_ex_pps_status_flag_omf: in     vl_logic;
        prl_tx_if_ex_pps_status_flag_ptp: in     vl_logic;
        prl_tx_if_ex_pps_status_output_current: in     vl_logic_vector(7 downto 0);
        prl_tx_if_ex_pps_status_output_voltage: in     vl_logic_vector(15 downto 0);
        prl_tx_st_message_construct_reset: in     vl_logic;
        prl_tx_st_message_construct_req: in     vl_logic;
        prl_tx_st_messageid_counter: in     vl_logic_vector(2 downto 0);
        prl_tx_st_message_construct_ack: out    vl_logic;
        prl_tx_st_message_construct_ack_result: out    vl_logic;
        prl_rx_st_send_goodcrc_req: in     vl_logic;
        prl_rx_st_send_goodcrc_sop_type: in     vl_logic_vector(1 downto 0);
        prl_rx_st_send_goodcrc_messageid: in     vl_logic_vector(2 downto 0);
        prl_rx_st_send_goodcrc_ack: out    vl_logic;
        prl_rx_st_send_goodcrc_ack_result: out    vl_logic;
        prl_hdrst_send_req: in     vl_logic;
        prl_hdrst_send_ack: out    vl_logic;
        prl_hdrst_send_ack_result: out    vl_logic
    );
end prl_tx_message_path;
