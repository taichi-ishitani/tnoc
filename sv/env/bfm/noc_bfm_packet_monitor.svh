`ifndef NOC_BFM_PACKET_MONITOR_SVH
`define NOC_BFM_PACKET_MONITOR_SVH

typedef tue_param_monitor #(
  .CONFIGURATION  (noc_bfm_configuration  ),
  .STATUS         (noc_bfm_status         ),
  .ITEM           (noc_bfm_packet_item    )
) noc_bfm_packet_monitor_base;

class noc_bfm_packet_monitor extends noc_bfm_component_base #(
  noc_bfm_packet_monitor_base
);
  noc_bfm_flit_vif    vif;
  noc_bfm_packet_item packet_item;
  noc_bfm_flit_item   flit_item;
  noc_bfm_flit_item   flit_items[$];
  bit                 is_tx_monitor;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = (is_tx_monitor) ? configuration.tx_vif : configuration.rx_vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.monitor_cb) begin
      if (!vif.rst_n) begin
        do_reset();
      end
      else begin
        if (vif.monitor_cb.valid && (packet_item == null)) begin
          packet_item = create_item("packet_item");
        end
        if (vif.monitor_cb.valid && (flit_item == null)) begin
          flit_item = sample_flit_item();
        end

        if (!(vif.monitor_cb.valid && vif.monitor_cb.ready)) begin
          continue;
        end

        finish_flit_item();
        if (flit_items[$].is_tail_flit()) begin
          finish_packet_item();
        end
      end
    end
  endtask

  function void do_reset();
    packet_item = null;
    flit_item   = null;
    flit_items.delete();
  endfunction

  function noc_bfm_flit_item sample_flit_item();
    noc_bfm_flit_item flit_item;
    flit_item = noc_bfm_flit_item::type_id::create("flit_item");
    flit_item.unpack_flit(vif.monitor_cb.flit);
    void'(begin_child_tr(flit_item, packet_item.tr_handle));
    return flit_item;
  endfunction

  function void finish_flit_item();
    flit_items.push_back(flit_item);
    end_tr(flit_item);
    flit_item = null;
  endfunction

  function void finish_packet_item();
    packet_item.unpack_flit_items(flit_items);
    write_item(packet_item);
    flit_items.delete();
    packet_item = null;
  endfunction

  `tue_component_default_constructor(noc_bfm_packet_monitor)
endclass

class noc_bfm_packet_tx_monitor extends noc_bfm_packet_monitor;
  function new(string name = "noc_bfm_packet_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
    is_tx_monitor = 1;
  endfunction

  `uvm_component_utils(noc_bfm_packet_tx_monitor)
endclass

class noc_bfm_packet_rx_monitor extends noc_bfm_packet_monitor;
  function new(string name = "noc_bfm_packet_rx_monitor", uvm_component parent = null);
    super.new(name, parent);
    is_tx_monitor = 0;
  endfunction

  `uvm_component_utils(noc_bfm_packet_rx_monitor)
endclass
`endif
