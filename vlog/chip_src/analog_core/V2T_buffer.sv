
module V2T_buffer #(parameter Nctl_dcdl_fine = 2) (input clk_in, input clk_div, input [Nctl_dcdl_fine-1:0] ctl_dcdl_early, input [Nctl_dcdl_fine-1:0] ctl_dcdl_late, input CDN, input SDN, output clk_v2t_e, output clk_v2t_eb, output clk_v2t, output clk_v2tb, output clk_v2t_l, output clk_v2t_lb, output clk_divb);

//synopsys dc_script_begin
// set_dont_touch {clk* nor*}
//synopsys dc_script_end

inv_v2t_4_fixed iinv_clk_divb_dont_touch (.in(clk_div), .out(clk_divb));

ff_cn_sn_rn_fixed clk_div_sampled_reg_dont_touch (.D(clk_div), .CPN(clk_in), .Q(clk_div_sampled), .CDN(CDN), .SDN(SDN));

dcdl_fine idcdl_fine1 (.in(clk_div_sampled), .ctl(ctl_dcdl_early), .out(clk_div_sampled_d), .en(1'b1), .disable_state(1'b0));
dcdl_fine idcdl_fine2 (.in(clk_div_sampled_d), .ctl(ctl_dcdl_late), .out(clk_div_sampled_dd), .en(1'b1), .disable_state(1'b0));

n_or_v2t_fixed in_or1_dont_touch(.in1(clk_divb), .in2(clk_div_sampled), .out(nor_out1));
n_or_v2t_fixed in_or2_dont_touch(.in1(clk_divb), .in2(clk_div_sampled_d), .out(nor_out2));
n_or_v2t_fixed in_or3_dont_touch(.in1(clk_divb), .in2(clk_div_sampled_dd), .out(nor_out3));

V2T_clock_gen_S2D iS2D1_dont_touch(.in(nor_out1), .out(clk_v2t_e), .outb(clk_v2t_eb));
V2T_clock_gen_S2D iS2D2_dont_touch(.in(nor_out2), .out(clk_v2t), .outb(clk_v2tb));
V2T_clock_gen_S2D iS2D3_dont_touch(.in(nor_out3), .out(clk_v2t_l), .outb(clk_v2t_lb));


endmodule


