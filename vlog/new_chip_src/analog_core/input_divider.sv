 module input_divider ( 
 input in, 
 input en, 
 input en_meas, 
 input [2:0] ndiv, 
 input bypass_div, 
 input bypass_div2, 
 output out, 
 output out_meas 
 );

 ff_c_rn  iff_c_rn_dont_touch (  .CDN(en), .CP(in), .D(div2), .Q(ff_out) );
 inv iinv_1_dont_touch (  .in(ff_out), .out(div2) );
 
 mux imux_1_dont_touch ( .sel(bypass_div2), .in1(in), .in0(div2), .out(mux1_out) );

 inv iinv_2_dont_touch (  .in(mux1_out), .out(net1) );
 inv iinv_3_dont_touch (  .in(net1), .out(mux1_out_buff) );

 sync_divider  isync_divider_dont_touch ( .rstb(en), .in(mux1_out_buff), .ndiv(ndiv[2:0]), .out(div_out));

 mux imux_2_dont_touch ( .sel(bypass_div), .in1(mux1_out_buff), .in0(div_out), .out(mux2_out) ); 

 inv iinv_4_dont_touch (  .in(mux2_out), .out(net2) );
 inv iinv_5_dont_touch (  .in(net2), .out(out) );
 
 a_nd ia_nd_dont_touch (  .in2(en_meas), .in1(out), .out(net3) );
 inv iinv_6_dont_touch (  .in(net3), .out(net4) );
 inv iinv_7_dont_touch (  .in(net4), .out(out_meas) );

 endmodule
