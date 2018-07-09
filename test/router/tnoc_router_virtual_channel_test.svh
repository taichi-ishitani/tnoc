`ifndef TNOC_ROUTER_VIRTUAL_CHANNEL_TEST_SVH
`define TNOC_ROUTER_VIRTUAL_CHANNEL_TEST_SVH
class tnoc_router_virtual_channel_test_sequence extends tnoc_router_test_sequence_base;
  tnoc_bfm_location_id  sources[2];
  tnoc_bfm_location_id  destinations[2];

  task body();
    setup();
    fork
      do_noc_access(0);
      do_noc_access(1);
    join
  endtask

  function void setup();
    tnoc_bfm_location_id  port_list[5]  = '{
      '{x: 2, y: 1}, '{x: 0, y: 1},
      '{x: 1, y: 2}, '{x: 1, y: 0},
      '{x: 1, y: 1}
   };

    port_list.shuffle();
    sources[0]  = port_list[0];
    sources[1]  = port_list[1];

    port_list.shuffle();
    destinations[0] = port_list[0];
    destinations[1] = port_list[1];
  endfunction

  task do_noc_access(int index);
    uvm_sequencer_base  sequencer;

    foreach (configuration.bfm_cfg[i]) begin
      if (
        (configuration.bfm_cfg[i].id_x == sources[index].x) &&
        (configuration.bfm_cfg[i].id_y == sources[index].y)
      ) begin
        sequencer = p_sequencer.bfm_sequencer[i];
        break;
      end
    end

    for (int i = 0;i < 20;++i) begin
      tnoc_bfm_transmit_packet_sequence transmit_packet_sequence;
      `uvm_do_on_with(transmit_packet_sequence, sequencer, {
        ((i % 2) == 0) -> packet_type inside {TNOC_BFM_RESPONSE, TNOC_BFM_RESPONSE_WITH_DATA};
        ((i % 2) == 1) -> packet_type inside {TNOC_BFM_READ, TNOC_BFM_POSTED_WRITE, TNOC_BFM_NON_POSTED_WRITE};
        ((i % 2) == index) -> destination_id == destinations[0];
        ((i % 2) != index) -> destination_id == destinations[1];
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_router_virtual_channel_test_sequence)
  `uvm_object_utils(tnoc_router_virtual_channel_test_sequence)
endclass

class tnoc_router_virtual_channel_test extends tnoc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", tnoc_router_virtual_channel_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(tnoc_router_virtual_channel_test)
  `uvm_component_utils(tnoc_router_virtual_channel_test)
endclass
`endif
