library verilog;
use verilog.vl_types.all;
entity phy_crc32 is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        crc_data_in     : in     vl_logic_vector(3 downto 0);
        crc_data_en     : in     vl_logic;
        crc_data_last   : in     vl_logic;
        crc_out_fail    : out    vl_logic;
        crc_out         : out    vl_logic_vector(31 downto 0)
    );
end phy_crc32;
