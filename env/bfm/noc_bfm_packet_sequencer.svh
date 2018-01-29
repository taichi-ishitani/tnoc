`ifndef NOC_BFM_PACKET_SEQUENCER_SVH
`define NOC_BFM_PACKET_SEQUENCER_SVH

typedef tue_sequencer #(
  .CONFIGURATION  (noc_bfm_configuration  ),
  .STATUS         (noc_bfm_status         ),
  .REQ            (noc_bfm_packet_item    )
) noc_bfm_packet_sequencer_base;

class noc_bfm_packet_sequencer extends noc_bfm_packet_sequencer_base;
  typedef noc_bfm_packet_sequencer  this_type;

  uvm_analysis_imp #(noc_bfm_packet_item, this_type)  rx_packet_export;

  uvm_event packet_waiters[$];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rx_packet_export  = new("rx_packet_export", this);
  endfunction

  function void write(noc_bfm_packet_item packet_item);
    foreach (packet_waiters[i]) begin
      packet_waiters[i].trigger(packet_item);
    end
    packet_waiters.delete();
  endfunction

  task get_rx_packet(ref noc_bfm_packet_item packet_item);
    uvm_event waiter  = get_packet_waiter();
    waiter.wait_ptrigger();
    $cast(packet_item, waiter.get_trigger_data());
  endtask

  task get_rx_request_packet(ref noc_bfm_packet_item packet_item);
    while (1) begin
      noc_bfm_packet_item item;
      get_rx_packet(item);
      if (item.is_request()) begin
        packet_item = item;
        return;
      end
    end
  endtask

  task get_rx_response_packet(ref noc_bfm_packet_item packet_item);
    while (1) begin
      noc_bfm_packet_item item;
      get_rx_packet(item);
      if (item.is_response()) begin
        packet_item = item;
        return;
      end
    end
  endtask

  function uvm_event get_packet_waiter();
    uvm_event waiter  = new();
    packet_waiters.push_back(waiter);
    return waiter;
  endfunction

  `tue_component_default_constructor(noc_bfm_packet_sequencer)
  `uvm_component_utils(noc_bfm_packet_sequencer)
endclass
`endif
