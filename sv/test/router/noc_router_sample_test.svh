`ifndef NOC_ROUTER_SAMPLE_TEST_SVH
`define NOC_ROUTER_SAMPLE_TEST_SVH
class noc_router_sample_test_sequence extends noc_router_test_sequence_base;
  task body();
    fork
      request_process();
      response_process();
    join
  endtask

  task request_process();
    repeat (10) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, p_sequencer, {
        packet_type inside {
          NOC_BFM_READ, NOC_BFM_POSTED_WRITE, NOC_BFM_NON_POSTED_WRITE
        };
      })
    end
  endtask

  task response_process();
    repeat (10) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, p_sequencer, {
        packet_type inside {
          NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA
        };
      })
    end
  endtask

  `tue_object_default_constructor(noc_router_sample_test_sequence)
  `uvm_object_utils(noc_router_sample_test_sequence)
endclass

class noc_router_sample_test extends noc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    uvm_config_db #(uvm_object_wrapper)::set(packet_sequencer, "main_phase", "default_sequence", noc_router_sample_test_sequence::type_id::get());
  endfunction
  `tue_component_default_constructor(noc_router_sample_test)
  `uvm_component_utils(noc_router_sample_test)
endclass
`endif
