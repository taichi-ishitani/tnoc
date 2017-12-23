`ifndef NOC_ROUTER_SAMPLE_TEST_SVH
`define NOC_ROUTER_SAMPLE_TEST_SVH
class noc_router_sample_test_sequence extends noc_router_test_sequence_base;
  task body();
    main_process(0);
    main_process(1);
    main_process(2);
    main_process(3);
    main_process(4);
  endtask

  task main_process(int port);
    do_noc_access(port, 2, 1);
    do_noc_access(port, 0, 1);
    do_noc_access(port, 1, 2);
    do_noc_access(port, 1, 0);
    do_noc_access(port, 1, 1);
  endtask

  task do_noc_access(int port, int x, int y);
    for (int i =0;i < 20;++i) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, p_sequencer.bfm_sequencer[port], {
        destination_id.x == x;
        destination_id.y == y;
        if ((i % 2) == 0) {
          packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA};
        }
        else {
          packet_type inside {NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE};
        }
      })
    end
  endtask

  `tue_object_default_constructor(noc_router_sample_test_sequence)
  `uvm_object_utils(noc_router_sample_test_sequence)
endclass

class noc_router_sample_test extends noc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", noc_router_sample_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(noc_router_sample_test)
  `uvm_component_utils(noc_router_sample_test)
endclass
`endif
