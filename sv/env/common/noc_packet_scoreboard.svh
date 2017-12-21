`ifndef NOC_PACKET_SCOREBOARD_SVH
`define NOC_PACKET_SCOREBOARD_SVH
class noc_packet_scoreboard extends tue_scoreboard #(noc_bfm_configuration);
  uvm_analysis_imp_tx #(noc_bfm_packet_item, noc_packet_scoreboard) tx_packet_export;
  uvm_analysis_imp_rx #(noc_bfm_packet_item, noc_packet_scoreboard) rx_packet_export;

  noc_bfm_packet_item tx_item_queue[noc_bfm_location_id][noc_bfm_vc][$];
  uvm_phase           runtime_phase;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tx_packet_export  = new("tx_packet_export", this);
    rx_packet_export  = new("rx_packet_export", this);
  endfunction

  task run_phase(uvm_phase phase);
    runtime_phase = phase;
  endtask

  virtual function void write_tx(noc_bfm_packet_item item);
    if (is_acceptable_item(item)) begin
      noc_bfm_location_id source_id = item.source_id;
      noc_bfm_vc          vc        = item.virtual_channel;
      raise_objection();
      tx_item_queue[source_id][vc].push_back(item);
    end
  endfunction

  virtual function void write_rx(noc_bfm_packet_item item);
    noc_bfm_location_id source_id = item.source_id;
    noc_bfm_vc          vc        = item.virtual_channel;
    noc_bfm_packet_item tx_item;

    if (is_unexpected_item(source_id, vc)) begin
      `uvm_error(get_name(), $sformatf("unexpected item:\n%s", item.sprint()))
      return;
    end

    tx_item = tx_item_queue[source_id][vc].pop_front();
    if (item.compare(tx_item)) begin
      `uvm_info(get_name(), $sformatf("rx packet is mathced with tx packet:\n%s", item.sprint()), UVM_MEDIUM)
    end
    else begin
      `uvm_error(
        get_name(),
        $sformatf(
          "rx packet is not matched with tx packet:\ntx packet\n%s\nrx packet\n%s",
          tx_item.sprint(), item.sprint()
        )
      )
    end

    drop_objection();
  endfunction

  virtual function bit is_acceptable_item(noc_bfm_packet_item item);
    return 1;
  endfunction

  function bit is_unexpected_item(noc_bfm_location_id source_id, noc_bfm_vc vc);
    if (!tx_item_queue.exists(source_id)) begin
      return 1;
    end
    if (!tx_item_queue[source_id].exists(vc)) begin
      return 1;
    end
    if (tx_item_queue[source_id][vc].size() == 0) begin
      return 1;
    end
    return 0;
  endfunction

  function void raise_objection();
    foreach (tx_item_queue[i, j]) begin
      if (tx_item_queue[i][j].size() > 0) begin
        return;
      end
    end
    runtime_phase.raise_objection(this);
  endfunction

  function void drop_objection();
    foreach (tx_item_queue[i, j]) begin
      if (tx_item_queue[i][j].size() > 0) begin
        return;
      end
    end
    runtime_phase.drop_objection(this);
  endfunction

  `tue_component_default_constructor(noc_packet_scoreboard)
  `uvm_component_utils(noc_packet_scoreboard)
endclass
`endif
