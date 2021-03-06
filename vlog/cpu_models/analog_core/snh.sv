/********************************************************************
filename: snh.sv

Description:
Behavioal model of 1st sample & hold circuits.
1. (-) input delayed by `skew` parameter for modeling the skew between 
   two inputs
2. Wire+Switch RC effect is modeled as a two pole low-pass filter 

Assumptions:

Todo:
    - As of now, the simple loopback test fails if snh_obj.TD > 3ps.

********************************************************************/

`include "mLingua_pwl.vh"

module snh import const_pack::*; (
    input wire logic [Nout-1:0] clk,     // sampling clocks of the first s&h sw group
    input wire logic [Nout-1:0] clkb,    // ~clkb
    input pwl in_p,                      // + signal input
    input pwl in_n,                      // - signal input
    output pwl out_p [Nout-1:0],         // sampled (+) outputs
    output pwl out_n [Nout-1:0]          // sampled (-) outputs
);

import model_pack::SnHParameter;
import model_pack::ETOL_SNH;

// design parameter class instantiation

SnHParameter snh_obj;

// variables

real fp1, fp2;      // filter poles
real td_p, td_n;    // input delays

// wires

pwl in_p_d;    // delayed input (+) modeling skew
pwl in_n_d;    // delayed input (-) modeling skew
pwl filt_p;    // RC filtered (+) input
pwl filt_n;    // RC filtered (-) input

// initialize class parameters
real snh_obj_skew;
initial begin
    snh_obj = new();
    `ifdef RANDOMIZE
        snh_obj_skew = snh_obj.skew;
    `else
        snh_obj_skew = 0.0;
    `endif
    td_p = snh_obj.TD;
    td_n = snh_obj.TD + snh_obj_skew;
    fp1 = snh_obj.FP1;
    fp2 = snh_obj.FP2;
end

///////////////////////////////////
// Model Body
///////////////////////////////////

// input skew: delay in_n by `skew`

pwl_delay_prim i_delay_p (
    .delay(td_p),
    .in(in_p),
    .out(in_p_d)
);

pwl_delay_prim i_delay_n (
    .delay(td_n),
    .in(in_n),
    .out(in_n_d)
);

// wire+switch RC

pwl_filter_real_w_reset #(
    .filter(1), // i.e., 2-pole LPF
    .etol(ETOL_SNH)
) i_filt_p (
    .in(in_p_d),
    .out(filt_p),
    .fp1(fp1),
    .fp2(fp2)
);

pwl_filter_real_w_reset  #(
    .filter(1), // i.e., 2-pole LPF
    .etol(ETOL_SNH)
) i_filt_n (
    .in(in_n_d),
    .out(filt_n),
    .fp1(fp1),
    .fp2(fp2)
);

// first stage sample and hold

generate
    for (genvar i=0; i<Nout; i=i+1) begin: genblk1
        snh_1st uSNH ( 
            .inp(filt_p), 
            .inn(filt_n), 
            .clk(clk[i]), 
            .outp(out_p[i]), 
            .outn(out_n[i])
        );
        
    end
endgenerate

endmodule
