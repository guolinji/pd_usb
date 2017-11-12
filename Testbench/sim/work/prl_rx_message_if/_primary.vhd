library verilog;
use verilog.vl_types.all;
entity prl_rx_message_if is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pl2pe_rx_en     : out    vl_logic;
        pl2pe_rx_type   : out    vl_logic_vector(6 downto 0);
        pl2pe_rx_sop_type: out    vl_logic_vector(2 downto 0);
        pl2pe_rx_info   : out    vl_logic_vector(22 downto 0);
        prl_rx_st_inform_pe_en: in     vl_logic;
        prl_rx_parser_message_type: in     vl_logic_vector(1 downto 0);
        prl_rx_parser_sop_type: in     vl_logic_vector(2 downto 0);
        prl_rx_parser_header_type: in     vl_logic_vector(4 downto 0);
        prl_rx_parser_data_bist_mode: in     vl_logic;
        prl_rx_parser_data_request_pdo_type: in     vl_logic;
        prl_rx_parser_data_request_op_cur: in     vl_logic_vector(10 downto 0);
        prl_rx_parser_data_request_max_op_cur: in     vl_logic_vector(9 downto 0);
        prl_rx_parser_data_request_mismatch_flag: in     vl_logic
    );
end prl_rx_message_if;
