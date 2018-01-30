`ifndef TNOC_BFM_PACKET_MONITOR_SVH
`define TNOC_BFM_PACKET_MONITOR_SVH

typedef tue_param_monitor #(
  .CONFIGURATION  (tnoc_bfm_configuration ),
  .STATUS         (tnoc_bfm_status        ),
  .ITEM           (tnoc_bfm_packet_item   )
) tnoc_bfm_packet_monitor_base;

class tnoc_bfm_packet_monitor extends tnoc_bfm_component_base #(
  tnoc_bfm_packet_monitor_base
);
  tnoc_bfm_flit_vif     vif;
  tnoc_bfm_packet_item  packet_item[int];
  tnoc_bfm_flit_item    flit_item;
  tnoc_bfm_flit_item    flit_items[int][$];
  bit                   is_tx_monitor;

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
        int vc  = get_vc();

        if ((vif.monitor_cb.valid != '0) && (packet_item[vc] == null)) begin
          packet_item[vc] = create_item("packet_item");
        end
        if ((vif.monitor_cb.valid != '0)  && (flit_item == null)) begin
          flit_item = sample_flit_item(vc);
        end

        if ((vif.monitor_cb.valid & vif.monitor_cb.ready) == '0) begin
          continue;
        end

        finish_flit_item(vc);
        if (flit_items[vc][$].is_tail_flit()) begin
          finish_packet_item(vc);
        end
      end
    end
  endtask

  function void do_reset();
    packet_item.delete();
    flit_item   = null;
    flit_items.delete();
  endfunction

  function tnoc_bfm_flit_item sample_flit_item(int vc);
    tnoc_bfm_flit_item  flit_item;
    flit_item = tnoc_bfm_flit_item::type_id::create("flit_item");
    flit_item.unpack_flit(vif.monitor_cb.flit);
    void'(begin_child_tr(flit_item, packet_item[vc].tr_handle));
    return flit_item;
  endfunction

  function void finish_flit_item(int vc);
    flit_items[vc].push_back(flit_item);
    end_tr(flit_item);
    flit_item = null;
  endfunction

  function void finish_packet_item(int vc);
    packet_item[vc].unpack_flit_items(flit_items[vc]);
    write_item(packet_item[vc]);
    flit_items[vc].delete();
    packet_item[vc] = null;
  endfunction

  function int get_vc();
    if (vif.monitor_cb.valid != '0) begin
      return $clog2(vif.monitor_cb.valid);
    end
    else begin
      return 0;
    end
  endfunction

  `tue_component_default_constructor(tnoc_bfm_packet_monitor)
endclass

class tnoc_bfm_packet_tx_monitor extends tnoc_bfm_packet_monitor;
  function new(string name = "tnoc_bfm_packet_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
    is_tx_monitor = 1;
  endfunction

  `uvm_component_utils(tnoc_bfm_packet_tx_monitor)
endclass

class tnoc_bfm_packet_rx_monitor extends tnoc_bfm_packet_monitor;
  function new(string name = "tnoc_bfm_packet_rx_monitor", uvm_component parent = null);
    super.new(name, parent);
    is_tx_monitor = 0;
  endfunction

  `uvm_component_utils(tnoc_bfm_packet_rx_monitor)
endclass
`endif
