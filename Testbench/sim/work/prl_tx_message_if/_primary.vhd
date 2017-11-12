library verilog;
use verilog.vl_types.all;
entity prl_tx_message_if is
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
        prl_tx_st_message_if_ack: in     vl_logic;
        prl_tx_st_message_if_ack_result: in     vl_logic_vector(1 downto 0);
        prl_tx_if_en    : out    vl_logic;
        prl_tx_if_sop_type: out    vl_logic_vector(2 downto 0);
        prl_tx_if_message_type: out    vl_logic_vector(1 downto 0);
        prl_tx_if_header_type: out    vl_logic_vector(4 downto 0);
        prl_tx_if_source_cap_table_select: out    vl_logic_vector(3 downto 0);
        prl_tx_if_source_cap_current: out    vl_logic;
        prl_tx_if_ex_message_data_size: out    vl_logic_vector(8 downto 0);
        prl_tx_if_ex_pps_status_flag_omf: out    vl_logic;
        prl_tx_if_ex_pps_status_flag_ptp: out    vl_logic;
        prl_tx_if_ex_pps_status_output_current: out    vl_logic_vector(7 downto 0);
        prl_tx_if_ex_pps_status_output_voltage: out    vl_logic_vector(15 downto 0)
    );
end prl_tx_message_if;
