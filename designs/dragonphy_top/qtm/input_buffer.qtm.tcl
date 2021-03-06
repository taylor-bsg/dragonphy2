source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model input_buffer

set_qtm_technology -library $::env(qtm_tech_lib)

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

set input_list {inp inm pd}
create_qtm_port $input_list -type input
set_qtm_port_load -type qtm_load -factor 2 $input_list

set output_list {clk clk_b}
create_qtm_port $output_list -type output
set_qtm_port_drive -type qtm_drive $output_list

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
