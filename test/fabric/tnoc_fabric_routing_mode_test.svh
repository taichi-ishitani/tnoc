`ifndef TNOC_FABRIC_ROUTING_MODE_TEST_SVH
`define TNOC_FABRIC_ROUTING_MODE_TEST_SVH
class tnoc_fabric_routing_mode_test_sequence extends tnoc_fabric_test_sequence_base;
  task body();
    fork
      do_noc_access(p_sequencer.bfm_sequencer[0][0], '{y: 1, x: 2}, TNOC_BFM_X_Y_ROUTING);
      do_noc_access(p_sequencer.bfm_sequencer[0][1], '{y: 2, x: 2}, TNOC_BFM_X_Y_ROUTING);
    join

    #(1us);

    fork
      do_noc_access(p_sequencer.bfm_sequencer[0][0], '{y: 1, x: 2}, TNOC_BFM_X_Y_ROUTING);
      do_noc_access(p_sequencer.bfm_sequencer[0][1], '{y: 2, x: 2}, TNOC_BFM_Y_X_ROUTING);
    join
  endtask

  task do_noc_access(
    uvm_sequencer_base    sequencer,
    tnoc_bfm_location_id  destination_id,
    tnoc_bfm_routing_mode routing_mode
  );
    repeat (20) begin
      tnoc_bfm_transmit_packet_sequence transmit_packet_sequence;
      `uvm_do_on_with(transmit_packet_sequence, sequencer, {
        destination_id == local::destination_id;
        burst_length   >= 8;
        routing_mode   == local::routing_mode;
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_fabric_routing_mode_test_sequence)
  `uvm_object_utils(tnoc_fabric_routing_mode_test_sequence)
endclass

class tnoc_fabric_routing_mode_test extends tnoc_fabric_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", tnoc_fabric_routing_mode_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(tnoc_fabric_routing_mode_test)
  `uvm_component_utils(tnoc_fabric_routing_mode_test)
endclass
`endif
