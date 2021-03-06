create_qtm_model butterphy_top
create_qtm_port {ext_Vcal ext_rx_inp ext_rx_inn ext_Vcm ext_rx_inp_test ext_rx_inn_test ext_clk_async_p ext_clk_async_n ext_clk_test0_p ext_clk_test0_n ext_clk_test1_p ext_clk_test1_n ext_clkp ext_clkn ext_rstb ext_dump_start jtag_intf_i_phy_tdi jtag_intf_i_phy_tck jtag_intf_i_phy_tms jtag_intf_i_phy_trst_n} -type input
create_qtm_port { clk_out_p clk_out_n clk_trig_p clk_trig_n jtag_intf_i_phy_tdo } -type output
set_qtm_port_load {ext_Vcal ext_rx_inp ext_rx_inn ext_Vcm ext_rx_inp_test ext_rx_inn_test ext_clk_async_p ext_clk_async_n ext_clk_test0_p ext_clk_test0_n ext_clk_test1_p ext_clk_test1_n ext_clkp ext_clkn ext_rstb ext_dump_start jtag_intf_i_phy_tdi jtag_intf_i_phy_tck jtag_intf_i_phy_tms jtag_intf_i_phy_trst_n} -value 0.1
set_qtm_port_drive {clk_out_p clk_out_n clk_trig_p clk_trig_n jtag_intf_i_phy_tdo} -value 1
redirect qtm.rpt report_qtm_model
save_qtm_model -format {lib db} -library_cell
exit
