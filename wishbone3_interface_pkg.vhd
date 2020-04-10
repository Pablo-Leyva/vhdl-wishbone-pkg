library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package wishbone3_interface_pkg is

    type wishbone3_interface_cnf_t is record
        data_width : natural;
        addr_width : natural;
    end record wishbone3_interface_cnf_t;
    constant WISHBONE3_CNF_ZERO_C : wishbone3_interface_cnf_t := wishbone3_interface_cnf_t'(
        data_width => 32,
        addr_width => 32
    );

    type wishbone3_m2s_t is record
        addr : std_ulogic;
        data : std_ulogic_vector;
        sel  : std_ulogic_vector;
        we   : std_ulogic;
        stb  : std_ulogic;
        cyc  : std_ulogic;
    end record wishbone3_m2s_t;

    type wishbone3_s2m_t is record
        data : std_ulogic_vector;
        ack  : std_ulogic;
        err  : std_ulogic;
        rty  : std_ulogic;
    end record wishbone3_s2m_t;

    type wishbone3_interface_t is record
        m2s : wishbone3_m2s_t;
        s2m : wishbone3_s2m_t;
    end record axi_stream_interface_t;

end wishbone3_interface_pkg;

package body wishbone3_interface_pkg is

end wishbone3_interface_pkg;
