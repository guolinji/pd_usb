library verilog;
use verilog.vl_types.all;
entity prl_rx_message_path is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy2prl_rx_packet_en: in     vl_logic;
        phy2prl_rx_packet_type: in     vl_logic_vector(2 downto 0);
        phy2prl_rx_packet_done: in     vl_logic;
        phy2prl_rx_packet_result: in     vl_logic_vector(1 downto 0);
        phy2prl_rx_payload: in     vl_logic_vector(7 downto 0);
        phy2prl_rx_payload_req: in     vl_logic;
        prl_tx_if_source_cap_table_select: in     vl_logic_vector(3 downto 0);
        prl_rx_parser_message_req: out    vl_logic;
        prl_rx_parser_message_type: out    vl_logic_vector(1 downto 0);
        prl_rx_parser_sop_type: out    vl_logic_vector(2 downto 0);
        prl_rx_parser_header_type: out    vl_logic_vector(4 downto 0);
        prl_rx_parser_message_id: out    vl_logic_vector(2 downto 0);
        prl_rx_parser_message_ex_data_size: out    vl_logic_vector(8 downto 0);
        prl_rx_parser_data_bist_mode: out    vl_logic;
        prl_rx_parser_data_request_pdo_type: out    vl_logic;
        prl_rx_parser_data_request_op_cur: out    vl_logic_vector(10 downto 0);
        prl_rx_parser_data_request_max_op_cur: out    vl_logic_vector(9 downto 0);
        prl_rx_parser_data_request_mismatch_flag: out    vl_logic
    );
end prl_rx_message_path;
