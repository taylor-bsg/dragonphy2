    `default_nettype none

module digital_core import const_pack::*; (
    input wire logic clk_adc,                           
    input wire logic [Nadc-1:0] adcout [Nti-1:0],
    input wire logic [Nti-1:0]  adcout_sign ,
    input wire logic [Nadc-1:0] adcout_rep [Nti_rep-1:0],
    input wire logic [Nti_rep-1:0] adcout_sign_rep,
    input wire logic ext_rstb,
    input wire logic clk_async,
    output wire logic clk_cdr,  
    output wire logic  [Npi-1:0] int_pi_ctl_cdr [Nout-1:0],
    output wire logic clock_out_p,
    output wire logic clock_out_n,
    output wire logic trigg_out_p,
    output wire logic trigg_out_n,
    input wire logic ext_dump_start,
    acore_debug_intf.dcore adbg_intf_i,
    jtag_intf.target jtag_intf_i
);

    // internal signals
    cdr_debug_intf cdbg_intf_i ();
    sram_debug_intf sdbg_intf_i ();
    dcore_debug_intf ddbg_intf_i ();

    
  //  wire logic ext_rstb;
    wire logic rstb;
    wire logic clk_avg;
    wire logic [Nadc-1:0] adcout_retimed [Nti-1:0];
    wire logic [Nti-1:0] adcout_sign_retimed;
    wire logic [Nadc-1:0] adcout_retimed_rep [Nti_rep-1:0];
    wire logic [Nti_rep-1:0] adcout_sign_retimed_rep;
    wire logic [Npi-1:0] pi_ctl_cdr[Nout-1:0];
    wire logic int_clk_cdr;
    wire logic clk_cdr_in;
    wire logic sram_rstb;
    wire logic cdr_rstb;
   // wire logic bufferend_signals[15:0];
    wire logic buffered_signals[15:0];
    wire logic signed [Nadc-1:0] adcout_unfolded [Nti+Nti_rep-1:0];
    wire logic [Npi-1:0] scale_value [Nout-1:0];
    wire logic [Npi-1:0] unscaled_pi_ctl [Nout-1:0];
    wire logic [Npi+Npi-1:0] scaled_pi_ctl [Nout-1:0];



    assign rstb             = ddbg_intf_i.int_rstb  && ext_rstb; //combine external reset with JTAG reset\
    assign sram_rstb        = ddbg_intf_i.sram_rstb && ext_rstb;
    assign cdr_rstb         = ddbg_intf_i.cdr_rstb  && ext_rstb;
    //assign adbg_intf_i.rstb = rstb;

    assign clk_cdr = clk_cdr_in;

    assign buffered_signals[0]  = clk_adc;
    assign buffered_signals[1]  = adbg_intf_i.del_out_pi;
    assign buffered_signals[2]  = adbg_intf_i.pi_out_meas[0];
    assign buffered_signals[3]  = adbg_intf_i.pi_out_meas[1];
    assign buffered_signals[4]  = adbg_intf_i.pi_out_meas[2];
    assign buffered_signals[5]  = adbg_intf_i.pi_out_meas[3];
    assign buffered_signals[6]  = adbg_intf_i.del_out_rep[0];
    assign buffered_signals[7]  = adbg_intf_i.del_out_rep[1];
    assign buffered_signals[8]  = adbg_intf_i.inbuf_out_meas;
    assign buffered_signals[9]  = adbg_intf_i.pfd_inp_meas;
    assign buffered_signals[10] = adbg_intf_i.pfd_inn_meas;
    assign buffered_signals[11] = clk_cdr;
    assign buffered_signals[12] = clk_async;
    assign buffered_signals[13] = 0;
    assign buffered_signals[14] = 0;
    assign buffered_signals[15] = 0;

    //ADC Output Retimer

    ti_adc_retimer retimer_i (
        .clk_retimer(clk_adc),   // clock for serial to parallel retiming

        .in_data(adcout),   // serial data
        .in_sign(adcout_sign),                     // sign of serial data
        .in_data_rep(adcout_rep),
        .in_sign_rep(adcout_sign_rep),

        .out_data(adcout_retimed), // parallel data
        .out_sign(adcout_sign_retimed),
        .out_data_rep(adcout_retimed_rep), // parallel data
        .out_sign_rep(adcout_sign_retimed_rep) 
    );


    //PFD Offset Calibration

    //This generates a JTAG controled clock divider - divisble by 1 to 2^5 
    freq_divider #(.N(4)) average_clk_gen (.cki (clk_adc), .cko (clk_avg), .ndiv(ddbg_intf_i.Ndiv_clk_avg), .rstb(rstb));
    freq_divider #(.N(3)) cdr_inpt_clk_gen (.cki (clk_adc), .cko (clk_cdr_in), .ndiv(ddbg_intf_i.Ndiv_clk_cdr), .rstb(rstb));

    genvar k;

    generate
        for (k=0;k<Nti;k=k+1) begin : unfold_and_calibrate_PFD_by_slice
            adc_unfolding PFD_CALIB (
                //Inputs
                .clk_retimer(clk_adc),
                .rstb(rstb),
                .clk_avg(clk_avg),
                .din(adcout_retimed[k]),
                .sign_out(adcout_sign_retimed[k]),
                //Outputs
                .dout(adcout_unfolded[k]),
                //All of the following are JTAG related signals
                .en_pfd_cal(ddbg_intf_i.en_pfd_cal),
                .en_ext_pfd_offset(ddbg_intf_i.en_ext_pfd_offset),
                .ext_pfd_offset(ddbg_intf_i.ext_pfd_offset[k]),
                .Nbin(ddbg_intf_i.Nbin_adc),
                .Navg(ddbg_intf_i.Navg_adc),
                .DZ(ddbg_intf_i.DZ_hist_adc),
                .dout_avg(ddbg_intf_i.adcout_avg[k]),
                .dout_sum(ddbg_intf_i.adcout_sum[k]),
                .hist_center(ddbg_intf_i.adcout_hist_center[k]),
                .hist_side(ddbg_intf_i.adcout_hist_side[k]),
                .pfd_offset(ddbg_intf_i.pfd_offset[k])
            );
        end

        for (k=0;k<2;k=k+1) begin : replica_unfold_and_calib
            adc_unfolding PFD_CALIB_REP (
                //Inputs
                .clk_retimer(clk_adc),
                .rstb(rstb),
                .clk_avg(clk_avg),
                .din(adcout_retimed_rep[k]),
                .sign_out(adcout_sign_retimed_rep[k]),
                //Outputs
                .dout(adcout_unfolded[k+Nti]),
                //All of the following are JTAG related signals
                .en_pfd_cal(ddbg_intf_i.en_pfd_cal_rep),
                .en_ext_pfd_offset(ddbg_intf_i.en_ext_pfd_offset_rep),
                .ext_pfd_offset(ddbg_intf_i.ext_pfd_offset_rep[k]),
                .Nbin(ddbg_intf_i.Nbin_adc_rep),
                .Navg(ddbg_intf_i.Navg_adc_rep),
                .DZ(ddbg_intf_i.DZ_hist_adc_rep),
                .dout_avg(ddbg_intf_i.adcout_avg_rep[k]),
                .dout_sum(ddbg_intf_i.adcout_sum_rep[k]),
                .hist_center(ddbg_intf_i.adcout_hist_center_rep[k]),
                .hist_side(ddbg_intf_i.adcout_hist_side_rep[k]),
                .pfd_offset(ddbg_intf_i.pfd_offset_rep[k])
            );
        end
    endgenerate


    // CDR

    mm_cdr iMM_CDR (
        .clk_data(clk_adc),
        .clk_cdr(clk_cdr_in),
        .din(adcout_unfolded[Nti-1:0]),
        .ext_rstb(cdr_rstb),
        .sel_ext(ddbg_intf_i.en_ext_pi_ctl_cdr),
        .pi_ctl_ext(ddbg_intf_i.ext_pi_ctl_cdr),
        .Nlog_sample(ddbg_intf_i.Ndiv_clk_cdr),
        .pi_ctl(pi_ctl_cdr),
        .cdbg_intf_i(cdbg_intf_i)
    );
    genvar j;
    generate
        for (j=0; j<Nout; j=j+1) begin
            assign scale_value[j]        = (ddbg_intf_i.en_ext_max_sel_mux ? ddbg_intf_i.ext_max_sel_mux[j] : adbg_intf_i.max_sel_mux[j])<<4;
            assign unscaled_pi_ctl[j]    = pi_ctl_cdr[j] + ddbg_intf_i.ext_pi_ctl_offset[j];
            assign scaled_pi_ctl[j]      = unscaled_pi_ctl[j]*scale_value[j];
            assign int_pi_ctl_cdr[j]     = scaled_pi_ctl[j] >> Npi;
        end
    endgenerate
    // SRAM

    oneshot_memory oneshot_memory_i (
        .clk(clk_adc),
        .rstb(sram_rstb),
        
        .in_data(adcout_unfolded),

        .in_start_write(ext_dump_start),

        .in_addr(sdbg_intf_i.in_addr),

        .out_data(sdbg_intf_i.out_data),
        .addr(sdbg_intf_i.addr)
    );

    output_buffer out_buff_i (
            .bufferend_signals(buffered_signals),
            .sel_outbuff(ddbg_intf_i.sel_outbuff),
            .sel_trigbuff(ddbg_intf_i.sel_trigbuff),
            .en_outbuff(ddbg_intf_i.en_outbuff),
            .en_trigbuff(ddbg_intf_i.en_trigbuff),
            .Ndiv_outbuff(ddbg_intf_i.Ndiv_outbuff),
            .Ndiv_trigbuff(ddbg_intf_i.Ndiv_trigbuff),
            .bypass_out_div(ddbg_intf_i.bypass_out),
            .bypass_trig_div(ddbg_intf_i.bypass_trig),

            .clock_out_p(clock_out_p),
            .clock_out_n(clock_out_n),
            .trigg_out_p(trigg_out_p),
            .trigg_out_n(trigg_out_n)
    );
    // JTAG

    jtag jtag_i (
        .clk(clk_adc),
        .rstb(ext_rstb),
        .ddbg_intf_i(ddbg_intf_i),
        .adbg_intf_i(adbg_intf_i),
        .cdbg_intf_i(cdbg_intf_i),
        .sdbg_intf_i(sdbg_intf_i),
        .jtag_intf_i(jtag_intf_i)
    );

endmodule

`default_nettype wire