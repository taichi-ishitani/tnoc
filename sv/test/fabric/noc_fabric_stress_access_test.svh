`ifndef NOC_FABRIC_STRESS_ACCESS_TEST_SVH
`define NOC_FABRIC_STRESS_ACCESS_TEST_SVH
class noc_fabric_stress_access_test_sequence extends noc_fabric_test_sequence_base;
  task body();
    stress_access_test(0);
    stress_access_test(1);
    stress_access_test(2);
    stress_access_test(3);
  endtask

  task stress_access_test(int test_mode);
    noc_bfm_location_id destination;

    void'(std::randomize(destination) with {
      destination.x inside {[0:configuration.size_x-1]};
      destination.y inside {[0:configuration.size_y-1]};
    });

    foreach (p_sequencer.bfm_sequencer[y, x]) begin
      fork
        automatic uvm_sequencer_base  sequencer = p_sequencer.bfm_sequencer[y][x];
        do_noc_access(sequencer, destination, test_mode);
      join_none
    end

    wait fork;
  endtask

  task do_noc_access(uvm_sequencer_base sequencer, noc_bfm_location_id destination, int test_mode);
    for (int i = 0;i < 20;++i) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, sequencer, {
        destination_id == destination;
        length         >= 8;
        if (test_mode inside {[0:2]}) {
           packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
        }
        else if (test_mode inside {[3:5]}) {
          packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
        }
        else if (test_mode inside {[6:8]}) {
          ((i % 2) == 0) -> packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
          ((i % 2) == 1) -> packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
        }
        if ((test_mode % 3) == 0) {
          routing_mode == NOC_BFM_X_Y_ROUTING;
        }
        else if ((test_mode % 3) == 1) {
          routing_mode == NOC_BFM_Y_X_ROUTING;
        }
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
