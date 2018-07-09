`ifndef TNOC_ROUTER_STRESS_ACCESS_TEST_SVH
`define TNOC_ROUTER_STRESS_ACCESS_TEST_SVH
class tnoc_router_stress_access_test_sequence extends tnoc_router_test_sequence_base;
  tnoc_bfm_location_id  destination;

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
    tnoc_bfm_location_id  port_list[5]  = '{
      '{x: 2, y: 1}, '{x: 0, y: 1},
      '{x: 1, y: 2}, '{x: 1, y: 0},
      '{x: 1, y: 1}
    };
    port_list.shuffle;
    destination = port_list[0];
  endfunction

  task do_noc_access(int index);
    for (int i = 0;i < 20;++i) begin
      tnoc_bfm_transmit_packet_sequence transmit_packet_sequence;
      `uvm_do_on_with(transmit_packet_sequence, p_sequencer.bfm_sequencer[index], {
        destination_id == destination;
        ((i % 2) == 0) -> packet_type inside {TNOC_BFM_RESPONSE, TNOC_BFM_RESPONSE_WITH_DATA};
        ((i % 2) == 1) -> packet_type inside {TNOC_BFM_READ, TNOC_BFM_POSTED_WRITE, TNOC_BFM_NON_POSTED_WRITE};
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_router_stress_access_test_sequence)
  `uvm_object_utils(tnoc_router_stress_access_test_sequence)
endclass

class tnoc_router_stress_access_test extends tnoc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", tnoc_router_stress_access_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(tnoc_router_stress_access_test)
  `uvm_component_utils(tnoc_router_stress_access_test)
endclass
`endif
