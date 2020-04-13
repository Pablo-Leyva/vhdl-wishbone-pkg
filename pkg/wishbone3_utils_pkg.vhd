library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone3_interface_pkg.all;

package wishbone3_utils_pkg is

    type wishbone3_interface_array_t is array (natural range <>) of wishbone3_interface_t;
    type wishbone3_m2s_array_t is array (natural range <>) of wishbone3_m2s_t;
    type wishbone3_s2m_array_t is array (natural range <>) of wishbone3_s2m_t;

    pure function get_data_width( i : wishbone3_m2s_t )           return natural;
    pure function get_data_width( i : wishbone3_s2m_t )           return natural;
    pure function get_data_width( i : wishbone3_interface_t )     return natural;
    pure function get_data_width( i : wishbone3_interface_cnf_t ) return natural;

    pure function get_addr_width( i : wishbone3_interface_t )     return natural;
    pure function get_addr_width( i : wishbone3_m2s_t )           return natural;
    pure function get_addr_width( i : wishbone3_interface_cnf_t ) return natural;

    pure function get_sel_width(  i : wishbone3_interface_cnf_t ) return natural;

    --pure function get_data_width( i : wishbone3_interface_cnf_t ) return natural;
    --pure function get_addr_width( i : wishbone3_interface_cnf_t ) return natural;

    procedure to_wb3_interface ( signal wb3 : inout wishbone3_interface_t;
                                 signal m2s : in    wishbone3_m2s_t;
                                 signal s2m : out   wishbone3_s2m_t);

end wishbone3_utils_pkg;

package body wishbone3_utils_pkg is

    pure function get_data_width( i : wishbone3_m2s_t ) return natural is begin
        return i.data'length;
    end function get_data_width;

    pure function get_data_width( i : wishbone3_s2m_t ) return natural is
    begin
        return i.data'length;
    end function get_data_width;

    pure function get_data_width( i : wishbone3_interface_t ) return natural is
    begin
        return get_data_width(i.m2s);
    end function get_data_width;

    pure function get_data_width( i : wishbone3_interface_cnf_t ) return natural is
    begin
        return i.data_width;
    end function get_data_width;

    pure function get_addr_width( i : wishbone3_m2s_t ) return natural is begin
        return i.data'length;
    end function get_addr_width;

    pure function get_addr_width( i : wishbone3_interface_t ) return natural is
    begin
        return get_addr_width(i.m2s);
    end function get_addr_width;

    pure function get_addr_width( i : wishbone3_interface_cnf_t ) return natural is
    begin
        return i.addr_width;
    end function get_addr_width;

    pure function get_sel_width( i : wishbone3_interface_cnf_t ) return natural is
    begin
        return get_data_width(i)/8;
    end function get_sel_width;

    procedure to_wb3_interface (signal wb3 : inout wishbone3_interface_t;
                                signal m2s : in    wishbone3_m2s_t;
                                signal s2m : out   wishbone3_s2m_t) is
    begin
        wb3.m2s <= m2s;
        s2m     <= wb3.s2m;
    end procedure to_wb3_interface;

end wishbone3_utils_pkg;
