`ifndef TNOC_ROUTER_ROUTING_MODE_TEST_SVH
`define TNOC_ROUTER_ROUTING_MODE_TEST_SVH
class tnoc_router_routing_mode_test_sequence extends tnoc_router_test_sequence_base;
  task body();
    do_noc_access('{y: 0, x: 0});
    do_noc_access('{y: 0, x: 2});
    do_noc_access('{y: 2, x: 0});
    do_noc_access('{y: 2, x: 2});
  endtask

  task do_noc_access(tnoc_bfm_location_id destination_id);
    for (int i = 0;i < 20;++i) begin
      tnoc_bfm_packet_item  packet_item;
      `uvm_do_on_with(packet_item, p_sequencer.bfm_sequencer[4], {
        destination_id == local::destination_id;
        ((i % 2) == 0) -> routing_mode == TNOC_BFM_X_Y_ROUTING;
        ((i % 2) == 1) -> routing_mode == TNOC_BFM_Y_X_ROUTING;
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_router_routing_mode_test_sequence)
  `uvm_object_utils(tnoc_router_routing_mode_test_sequence)
endclass

class tnoc_router_routing_mode_test extends tnoc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", tnoc_router_routing_mode_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(tnoc_router_routing_mode_test)
  `uvm_component_utils(tnoc_router_routing_mode_test)
endclass
`endif
