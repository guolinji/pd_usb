library verilog;
use verilog.vl_types.all;
entity phy_definition_of_idle is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        phy_cc_signal   : in     vl_logic;
        phy_definition_of_idle_en: in     vl_logic;
        phy_definition_of_idle_done: out    vl_logic;
        phy_definition_of_idle_result: out    vl_logic
    );
end phy_definition_of_idle;
