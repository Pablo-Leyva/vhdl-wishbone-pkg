-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

context work.vunit_context;
context work.com_context;
use work.memory_pkg.all;
use work.wishbone_pkg.all;
use work.bus_master_pkg.all;

library osvvm;
use osvvm.RandomPkg.all;

use work.qkd_utils.all;

entity tb_wb3_cdc_sync is
generic(
    runner_cfg      : string
--    encoded_tb_cfg  : string
);
end entity;

architecture a of tb_wb3_cdc_sync is

--    type tb_cfg_t is record
--        axis_tdata_width    : positive;
--        dummy               : positive;
--    end record tb_cfg_t;
--
--    impure function decode(encoded_tb_cfg : string) return tb_cfg_t is
--    begin
--        return(
--            axis_tdata_width  => positive'value(get(encoded_tb_cfg, "axis_tdata_width")),
--            dummy             => positive'value(get(encoded_tb_cfg, "dummy"))
--        );
--    end function decode;

    constant WB_DATA_WIDTH_G : integer := 32;
    constant WB_ADDR_WIDTH_G : integer := 32;

    constant master_logger : logger_t  := get_logger("master");
    constant bus_handle : bus_master_t := new_bus(data_length    => WB_DATA_WIDTH_G,
                                                  address_length => WB_ADDR_WIDTH_G,
	                                                logger 	       => master_logger);

    signal wb_a_clk, wb_a_rst : std_ulogic := '0';
    signal wb_b_clk, wb_b_rst : std_ulogic := '0';

    constant wb_cnf_c : wishbone3_interface_cnf_t := wishbone3_interface_cnf_t'(addr_width => WB_ADDR_WIDTH_G,
                                                                                data_width => WB_DATA_WIDTH_G);
    signal wb_a, wb_b : wishbone3_interface_t(m2s(addr(get_addr_width(wb_cnf_c)-1 downto 0),
                                                  data(get_data_width(wb_cnf_c)-1 downto 0),
                                                  sel( get_sel_width( wb_cnf_c)-1 downto 0)),
                                              s2m(addr(get_addr_width(wb_cnf_c)-1 downto 0)));

begin

    main : process

        variable value_v : std_logic_vector(WB_DATA_WIDTH_G-1 downto 0) := (others => '1');
        variable tmp_v   : std_logic_vector(WB_DATA_WIDTH_G-1 downto 0) := (others => '0');

    begin

        test_runner_setup(runner, runner_cfg);

        wait for 100 ns;

        if run("cnf - single wr/rd") then

            write_bus(net, bus_handle, 0, value_v); --Write to CNF
            wait until wb_a.s2m.ack='1' and rising_edge(wb_a_clk);
            wait until rising_edge(wb_a_clk);

            wait for 100 ns;

            read_bus(net, bus_handle, 0, tmp_v); --Read from CNF

            wait for 100 ns;

            --check_equal(tmp_v, value_v, "Read/Write missmatch");

        elsif run("sts - single wr/rd") then

            write_bus(net, bus_handle, 0, value_v); --Write to CNF
            wait until wb_a.s2m.ack='1' and rising_edge(wb_a_clk);
            wait until rising_edge(wb_a_clk);

            wait for 100 ns;

            read_bus(net, bus_handle, 8, tmp_v); --Read from STS

            wait for 100 ns;

            --check_equal(tmp_v, value_v, "Read/Write missmatch");

        elsif run("trg - single wr") then

            write_bus(net, bus_handle, 4, value_v); --Write to TRG
            wait until wb_a.s2m.ack='1' and rising_edge(wb_a_clk);
            wait until rising_edge(wb_a_clk);

            wait for 100 ns;

        end if;

        test_runner_cleanup(runner);

    end process;

    test_runner_watchdog(runner, 10 ms);

    wb_master_inst : entity work.wishbone_master
    generic map(
        bus_handle => bus_handle)
    port map(
        clk   => wb_a_clk,
        adr   => wb_a.m2s.addr,
        dat_o => wb_a.m2s.data,
        dat_i => wb_a.s2m.data,
        sel   => wb_a.m2s.sel,
        cyc   => wb_a.m2s.cyc,
        stb   => wb_a.m2s.stb,
        we    => wb_a.m2s.we,
        stall => '0',--open,
        ack   => wb_a.s2m.ack or wb_a.s2m.err
    );

    inst_uut : entity work.wb3_cdc_sync
    generic map( wb_cnf_g => wb_cnf_c)
    port map(
        wb_a_clk => wb_a_clk,
        wb_a_rst => wb_a_rst,
        wb_a_m2s => wb_a.m2s,
        wb_a_s2m => wb_a.s2m,

        wb_b_clk => wb_b_clk,
        wb_b_rst => wb_b_rst,
        wb_b_m2s => wb_b.m2s,
        wb_b_s2m => wb_b.s2m
    );

    p_ack : process (wb_b_clk)
    begin
      if rising_edge(wb_b_clk) then wb_b.s2m.ack <= wb_b.m2s.cyc and wb_b.m2s.stb; end if;
    end process;

    wb_a_clk <= not wb_a_clk after 11 ns;
    wb_b_clk <= not wb_b_clk after 7 ns;

end architecture;
