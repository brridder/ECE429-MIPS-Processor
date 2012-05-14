library verilog;
use verilog.vl_types.all;
entity mem is
    generic(
        MEM_DEPTH       : integer := 1048578;
        MEM_WIDTH       : integer := 8
    );
    port(
        clock           : in     vl_logic;
        address         : in     vl_logic_vector(31 downto 0);
        data            : inout  vl_logic_vector(31 downto 0);
        wren            : in     vl_logic;
        q               : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_WIDTH : constant is 1;
end mem;
