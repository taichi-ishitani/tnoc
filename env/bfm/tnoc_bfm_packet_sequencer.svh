`ifndef TNOC_BFM_PACKET_SEQUENCER_SVH
`define TNOC_BFM_PACKET_SEQUENCER_SVH

typedef tue_sequencer #(
  .CONFIGURATION  (tnoc_bfm_configuration ),
  .STATUS         (tnoc_bfm_status        ),
  .REQ            (tnoc_bfm_packet_item   )
) tnoc_bfm_packet_sequencer_base;

class tnoc_bfm_packet_sequencer extends tnoc_bfm_packet_sequencer_base;
  typedef tnoc_bfm_packet_sequencer this_type;

  uvm_analysis_imp #(tnoc_bfm_packet_item, this_type) rx_packet_export;

  uvm_event packet_waiters[$];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rx_packet_export  = new("rx_packet_export", this);
  endfunction

  function void write(tnoc_bfm_packet_item packet_item);
    foreach (packet_waiters[i]) begin
      packet_waiters[i].trigger(packet_item);
    end
    packet_waiters.delete();
  endfunction

  task get_rx_packet(ref tnoc_bfm_packet_item packet_item);
    uvm_event waiter  = get_packet_waiter();
    waiter.wait_ptrigger();
    $cast(packet_item, waiter.get_trigger_data());
  endtask

  task get_rx_request_packet(ref tnoc_bfm_packet_item packet_item);
    while (1) begin
      tnoc_bfm_packet_item  item;
      get_rx_packet(item);
      if (item.is_request()) begin
        packet_item = item;
        return;
      end
    end
  endtask

  task get_rx_response_packet(ref tnoc_bfm_packet_item packet_item);
    while (1) begin
      tnoc_bfm_packet_item  item;
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

  `tue_component_default_constructor(tnoc_bfm_packet_sequencer)
  `uvm_component_utils(tnoc_bfm_packet_sequencer)
endclass
`endif
