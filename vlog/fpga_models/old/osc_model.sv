`include "signals.sv"

module osc_model #(
    parameter real t_lo=0.5e-9,
    parameter real t_hi=0.5e-9
) (
    output wire logic clk_o,
    output wire logic clk_o_val
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_clk_val;
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    (* dont_touch = "true" *) logic __emu_clk_i;

    // declare format for timestep
    `REAL_FROM_WIDTH_EXP(DT_FMT, `DT_WIDTH, `DT_EXPONENT);

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        // pass through real-valued parameters
        .t_lo(t_lo),
        .t_hi(t_hi),
        // pass formatting information
        `PASS_REAL(emu_dt, DT_FMT),
        `PASS_REAL(dt_req, DT_FMT)
    ) osc_model_core_i (
        .emu_rst(__emu_rst),
        .emu_clk(__emu_clk),
        .emu_dt(__emu_dt),
        .dt_req(__emu_dt_req),
        .clk_val(clk_o_val),
        .clk_i(__emu_clk_i),
        .clk_o(clk_o)
    );

    // assign to __emu_clk_val
    // TODO: clean this up; it's a particularly messy detail
    assign __emu_clk_val = clk_o_val;
endmodule