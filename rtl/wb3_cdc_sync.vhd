library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone3_interface_pkg.all;
use work.wishbone3_utils_pkg.all;

entity wb3_cdc_sync is
generic (
    wb_cnf_g : wishbone3_interface_cnf_t := WISHBONE3_CNF_ZERO_C
);
port (
    wb_a_clk : in  std_ulogic;
    wb_a_rst : in  std_ulogic;
    wb_a_m2s : in  wishbone3_m2s_t(addr(get_addr_width(wb_cnf_g)-1 downto 0),
                                   data(get_data_width(wb_cnf_g)-1 downto 0),
                                   sel( get_sel_width( wb_cnf_g)-1 downto 0));
    wb_a_s2m : out wishbone3_s2m_t(data(get_data_width(wb_cnf_g)-1 downto 0));

    wb_b_clk : in  std_ulogic;
    wb_b_rst : in  std_ulogic;
    wb_b_m2s : out wishbone3_m2s_t(addr(get_addr_width(wb_cnf_g)-1 downto 0),
                                   data(get_data_width(wb_cnf_g)-1 downto 0),
                                   sel( get_sel_width( wb_cnf_g)-1 downto 0));
    wb_b_s2m : in  wishbone3_s2m_t(data(get_data_width(wb_cnf_g)-1 downto 0))
);
end wb3_cdc_sync;

architecture behavioural of wb3_cdc_sync is

    signal wb_a_req_s,
           wb_b_req_s : std_ulogic;

    signal wb_a_pulse_req_s, wb_b_pulse_req_s : std_ulogic;
    signal wb_b_pulse_ack_resp_s, wb_b_pulse_err_resp_s, wb_b_pulse_rty_resp_s : std_ulogic;
    signal wb_a_pulse_ack_resp_s, wb_a_pulse_err_resp_s, wb_a_pulse_rty_resp_s : std_ulogic;

    signal req_b_rst_s,
           req_a_rst_s : std_ulogic;

begin

    --DATA ADDRESS AND DATA
    wb_b_m2s.addr <= wb_a_m2s.addr;
    wb_b_m2s.data <= wb_a_m2s.data;
    wb_b_m2s.sel  <= wb_a_m2s.sel;
    wb_b_m2s.we   <= wb_a_m2s.we;

    p_latch_wb_data_resp : process (wb_b_clk)
    begin
        if wb_b_pulse_ack_resp_s='1' then
            wb_a_s2m.data <= wb_b_s2m.data;
        end if;
    end process p_latch_wb_data_resp;

    --SYNCHRONIZE MASTER REQUEST
    wb_a_req_s <= wb_a_m2s.cyc and wb_a_m2s.stb;

    inst_req_to_pulse_req : entity work.edge_to_pulse
    generic map ( edge_g => "RISING" )
    port map( clk     => wb_a_clk,
              rst     => wb_a_rst or req_a_rst_s,
              input_i => wb_a_req_s,
              pulse_o => wb_a_pulse_req_s);

    inst_sync_pulse_req : entity work.sync_pulse
    port map( aclk=> wb_a_clk, arst=> wb_a_rst, apulse_i => wb_a_pulse_req_s,
              bclk=> wb_b_clk, brst=> wb_b_rst, bpulse_o => wb_b_pulse_req_s);

    inst_pulse_req_to_req : entity work.pulse_to_edge
    generic map ( edge_g => "RISING" )
    port map( clk     => wb_b_clk,
              rst     => wb_b_rst or req_b_rst_s,
              pulse_i => wb_b_pulse_req_s,
              level_o => wb_b_req_s);

    wb_b_m2s.cyc <= wb_b_req_s;
    wb_b_m2s.stb <= wb_b_req_s;

    --SYNCHRONIZE SLAVE RESPONSE
    wb_b_pulse_ack_resp_s <= wb_b_req_s and wb_b_s2m.ack;
    wb_b_pulse_err_resp_s <= wb_b_req_s and wb_b_s2m.err;
    wb_b_pulse_rty_resp_s <= wb_b_req_s and wb_b_s2m.rty;

    req_b_rst_s <= wb_b_pulse_ack_resp_s or wb_b_pulse_err_resp_s or wb_b_pulse_rty_resp_s;

    inst_sync_pulse_ack : entity work.sync_pulse
    port map( aclk=> wb_b_clk, arst=> wb_b_rst, apulse_i => wb_b_pulse_ack_resp_s,
              bclk=> wb_a_clk, brst=> wb_a_rst, bpulse_o => wb_a_pulse_ack_resp_s);

    inst_sync_pulse_err : entity work.sync_pulse
    port map ( aclk=> wb_b_clk, arst=> wb_b_rst, apulse_i => wb_b_pulse_err_resp_s,
               bclk=> wb_a_clk, brst=> wb_a_rst, bpulse_o => wb_a_pulse_err_resp_s);

    inst_sync_pulse_rty : entity work.sync_pulse
    port map( aclk=> wb_b_clk, arst=> wb_b_rst, apulse_i => wb_b_pulse_rty_resp_s,
              bclk=> wb_a_clk, brst=> wb_a_rst, bpulse_o => wb_a_pulse_rty_resp_s);

    req_a_rst_s <= wb_a_pulse_ack_resp_s or wb_a_pulse_err_resp_s or wb_a_pulse_rty_resp_s;

    wb_a_s2m.ack <= wb_a_req_s and wb_a_pulse_ack_resp_s;
    wb_a_s2m.err <= wb_a_req_s and wb_a_pulse_err_resp_s;
    wb_a_s2m.rty <= wb_a_req_s and wb_a_pulse_rty_resp_s;

end behavioural;
