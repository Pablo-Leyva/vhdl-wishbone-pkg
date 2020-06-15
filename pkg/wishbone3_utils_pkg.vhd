library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone3_interface_pkg.all;

package wishbone3_utils_pkg is

    type wishbone3_cnf_array_t is array (natural range <>) of wishbone3_interface_cnf_t;
    type wishbone3_interface_array_t is array (natural range <>) of wishbone3_interface_t;
    type wishbone3_m2s_array_t is array (natural range <>) of wishbone3_m2s_t;
    type wishbone3_s2m_array_t is array (natural range <>) of wishbone3_s2m_t;

    pure function new_wishbone_m2s( i : wishbone3_interface_cnf_t ) return wishbone3_m2s_t;
    pure function new_wishbone_s2m( i : wishbone3_interface_cnf_t ) return wishbone3_s2m_t;

    pure function new_wishbone_m2s_array( i : wishbone3_interface_cnf_t; n : positive ) return wishbone3_m2s_array_t;
    pure function new_wishbone_s2m_array( i : wishbone3_interface_cnf_t; n : positive ) return wishbone3_s2m_array_t;

    pure function get_data_width( i : wishbone3_m2s_t )           return natural;
    pure function get_data_width( i : wishbone3_s2m_t )           return natural;
    pure function get_data_width( i : wishbone3_interface_t )     return natural;
    pure function get_data_width( i : wishbone3_interface_cnf_t ) return natural;

    pure function get_addr_width( i : wishbone3_interface_t )     return natural;
    pure function get_addr_width( i : wishbone3_m2s_t )           return natural;
    pure function get_addr_width( i : wishbone3_interface_cnf_t ) return natural;

    pure function get_sel_width(  i : wishbone3_interface_cnf_t ) return natural;

    pure function wb_slice(  i : wishbone3_m2s_t; c : wishbone3_interface_cnf_t ) return wishbone3_m2s_t;

    --pure function get_data_width( i : wishbone3_interface_cnf_t ) return natural;
    --pure function get_addr_width( i : wishbone3_interface_cnf_t ) return natural;

    procedure to_wb3_interface ( signal wb3 : inout wishbone3_interface_t;
                                 signal m2s : in    wishbone3_m2s_t;
                                 signal s2m : out   wishbone3_s2m_t);

end wishbone3_utils_pkg;

package body wishbone3_utils_pkg is

    pure function new_wishbone_m2s( i : wishbone3_interface_cnf_t ) return wishbone3_m2s_t is
        variable wishbone3_m2s_v : wishbone3_m2s_t(addr(get_addr_width(i)-1 downto 0),
                                                   data(get_data_width(i)-1 downto 0),
                                                    sel(get_sel_width(i) -1 downto 0));
    begin
        wishbone3_m2s_v.addr := (others => '0');
        wishbone3_m2s_v.data := (others => '0');
        wishbone3_m2s_v.sel  := (others => '0');
        wishbone3_m2s_v.we   := '0';
        wishbone3_m2s_v.stb  := '0';
        wishbone3_m2s_v.cyc  := '0';
        return wishbone3_m2s_v;
    end;

    pure function new_wishbone_s2m( i : wishbone3_interface_cnf_t ) return wishbone3_s2m_t is
        variable wishbone3_s2m_v : wishbone3_s2m_t(data(get_data_width(i)-1 downto 0));
    begin
        wishbone3_s2m_v.data := (others => '0');
        wishbone3_s2m_v.ack  := '0';
        wishbone3_s2m_v.err  := '0';
        wishbone3_s2m_v.rty  := '0';
        return wishbone3_s2m_v;
    end;

    pure function new_wishbone_m2s_array(i : wishbone3_interface_cnf_t; n : positive) return wishbone3_m2s_array_t is
        variable wishbone3_m2s_array_v : wishbone3_m2s_array_t(0 to n-1)(addr(get_addr_width(i)-1 downto 0),
                                                                         data(get_data_width(i)-1 downto 0),
                                                                          sel(get_sel_width(i) -1 downto 0));
    begin
        for j in 0 to n-1 loop
            wishbone3_m2s_array_v(j) := new_wishbone_m2s(i);
         end loop;
        return wishbone3_m2s_array_v;
    end;

    pure function new_wishbone_s2m_array(i : wishbone3_interface_cnf_t; n : positive) return wishbone3_s2m_array_t is
        variable wishbone3_s2m_array_v : wishbone3_s2m_array_t(0 to n-1)(data(get_data_width(i)-1 downto 0));
    begin
        for j in 0 to n-1 loop
            wishbone3_s2m_array_v(j) := new_wishbone_s2m(i);
         end loop;
        return wishbone3_s2m_array_v;
    end;

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

    pure function wb_slice(  i : wishbone3_m2s_t; c : wishbone3_interface_cnf_t ) return wishbone3_m2s_t is
        variable wishbone3_m2s_v : wishbone3_m2s_t(addr(get_addr_width(c)-1 downto 0),
                                                   data(get_data_width(c)-1 downto 0),
                                                   sel( get_sel_width(c) -1 downto 0));
    begin
        wishbone3_m2s_v.addr := i.addr(wishbone3_m2s_v.addr'range);
        wishbone3_m2s_v.data := i.data(wishbone3_m2s_v.data'range);
        wishbone3_m2s_v.sel  := i.sel(wishbone3_m2s_v.sel'range);
        wishbone3_m2s_v.we   := i.we;
        wishbone3_m2s_v.stb  := i.stb;
        wishbone3_m2s_v.cyc  := i.cyc;
        return wishbone3_m2s_v;
    end function wb_slice;

    procedure to_wb3_interface (signal wb3 : inout wishbone3_interface_t;
                                signal m2s : in    wishbone3_m2s_t;
                                signal s2m : out   wishbone3_s2m_t) is
    begin
        wb3.m2s <= m2s;
        s2m     <= wb3.s2m;
    end procedure to_wb3_interface;

end wishbone3_utils_pkg;
