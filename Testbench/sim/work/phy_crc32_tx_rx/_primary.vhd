library verilog;
use verilog.vl_types.all;
entity phy_crc32_tx_rx is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_crc_tx_rx_select: in     vl_logic;
        phy_tx_packet_data_en: in     vl_logic;
        phy_tx_packet_data_in: in     vl_logic_vector(7 downto 0);
        phy_tx_packet_data_last: in     vl_logic;
        phy_tx_packet_crc: out    vl_logic_vector(31 downto 0);
        phy_rx_crc_data_in: in     vl_logic_vector(3 downto 0);
        phy_rx_crc_data_en: in     vl_logic;
        phy_rx_crc_data_last: in     vl_logic;
        phy_rx_crc_out_fail: out    vl_logic
    );
end phy_crc32_tx_rx;
