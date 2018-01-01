`ifndef NOC_FABRIC_STRESS_ACCESS_TEST_SVH
`define NOC_FABRIC_STRESS_ACCESS_TEST_SVH
class noc_fabric_stress_access_test_sequence extends noc_fabric_test_sequence_base;
  task body();
    noc_bfm_location_id destination;

    void'(std::randomize(destination) with {
      destination.x inside {[0:configuration.size_x-1]};
      destination.y inside {[0:configuration.size_y-1]};
    });

    foreach (p_sequencer.bfm_sequencer[y, x]) begin
      fork
        automatic uvm_sequencer_base  sequencer = p_sequencer.bfm_sequencer[y][x];
        do_noc_access(sequencer, destination);
      join_none
    end

    wait fork;
  endtask

  task do_noc_access(uvm_sequencer_base sequencer, noc_bfm_location_id destination);
    for (int i = 0;i < 20;++i) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, sequencer, {
        destination_id == destination;
        ((i % 2) == 0) -> packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
        ((i % 2) == 1) -> packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
      })
    end
  endtask

  `tue_object_default_constructor(noc_fabric_stress_access_test_sequence)
  `uvm_object_utils(noc_fabric_stress_access_test_sequence)
endclass

class noc_fabric_stress_access_test extends noc_fabric_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", noc_fabric_stress_access_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(noc_fabric_stress_access_test)
  `uvm_component_utils(noc_fabric_stress_access_test)
endclass
`endif
