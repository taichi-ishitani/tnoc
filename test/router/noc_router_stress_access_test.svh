`ifndef NOC_ROUTER_STRESS_ACCESS_TEST_SVH
`define NOC_ROUTER_STRESS_ACCESS_TEST_SVH
class noc_router_stress_access_test_sequence extends noc_router_test_sequence_base;
  noc_bfm_location_id destination;

  task body();
    setup();
    fork
      do_noc_access(0);
      do_noc_access(1);
      do_noc_access(2);
      do_noc_access(3);
      do_noc_access(4);
    join
  endtask

  function void setup();
    noc_bfm_location_id port_list[5]  = '{
      '{x: 2, y: 1}, '{x: 0, y: 1},
      '{x: 1, y: 2}, '{x: 1, y: 0},
      '{x: 1, y: 1}
    };
    port_list.shuffle;
    destination = port_list[0];
  endfunction

  task do_noc_access(int index);
    for (int i = 0;i < 20;++i) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, p_sequencer.bfm_sequencer[index], {
        destination_id == destination;
        ((i % 2) == 0) -> packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
        ((i % 2) == 1) -> packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
      })
    end
  endtask

  `tue_object_default_constructor(noc_router_stress_access_test_sequence)
  `uvm_object_utils(noc_router_stress_access_test_sequence)
endclass

class noc_router_stress_access_test extends noc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", noc_router_stress_access_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(noc_router_stress_access_test)
  `uvm_component_utils(noc_router_stress_access_test)
endclass
`endif
