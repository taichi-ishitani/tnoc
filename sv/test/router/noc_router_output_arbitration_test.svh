`ifndef NOC_ROUTER_OUTPUT_ARBITRATION_TEST_SEQUENCE_SVH
`define NOC_ROUTER_OUTPUT_ARBITRATION_TEST_SEQUENCE_SVH
class noc_router_output_arbitration_test_sequence extends noc_router_test_sequence_base;
  noc_bfm_location_id destinations[2];

  task body();
    setup();
    for (int i = 0;i < 2;++i) begin
      fork
        do_noc_access(p_sequencer.bfm_sequencer[0], i);
        do_noc_access(p_sequencer.bfm_sequencer[1], i);
        do_noc_access(p_sequencer.bfm_sequencer[2], i);
        do_noc_access(p_sequencer.bfm_sequencer[3], i);
        do_noc_access(p_sequencer.bfm_sequencer[4], i);
      join
    end
  endtask

  function void setup();
    noc_bfm_location_id port_list[5]  = '{
      '{x: 2, y: 1}, '{x: 0, y: 1},
      '{x: 1, y: 2}, '{x: 1, y: 0},
      '{x: 1, y: 1}
    };
    port_list.shuffle();
    destinations[0] = port_list[0];
    destinations[1] = port_list[1];
  endfunction

  task do_noc_access(uvm_sequencer_base sequencer, int index);
    for (int i = 0;i < 10;++i) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, sequencer, {
        if (index == 0) {
          packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
          destination_id == destinations[0];
        }
        else {
          packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
          destination_id == destinations[1];
        }

      })
    end
  endtask

  `tue_object_default_constructor(noc_router_output_arbitration_test_sequence)
  `uvm_object_utils(noc_router_output_arbitration_test_sequence)
endclass

class noc_router_output_arbitration_test extends noc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", noc_router_output_arbitration_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(noc_router_output_arbitration_test)
  `uvm_component_utils(noc_router_output_arbitration_test)
endclass
`endif
