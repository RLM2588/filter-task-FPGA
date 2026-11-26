#   vivado -mode batch -source build_lab12.tcl

set root     [file dirname [info script]]
set proj_dir [file join $root build]

file delete -force $proj_dir
create_project lab12_build $proj_dir -part xc7a35tcpg236-1 -force

add_files -norecurse [glob [file join $root lab12.srcs sources_1 new *.sv]]
add_files -norecurse [glob [file join $root lab12.srcs sources_1 imports sources_1 delay.sv]]

add_files -norecurse -fileset sim_1 [glob [file join $root lab12.srcs sim_1 new *.sv]]
add_files -norecurse -fileset sim_1 [glob [file join $root lab12.srcs sim_1 imports sim_1 *.vhd]]

set_property top lab12    [get_filesets sources_1]
set_property top tb_lab12 [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation
run all
close_sim

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1 -to_step route_design
wait_on_run impl_1

puts "=== DONE: $proj_dir ==="