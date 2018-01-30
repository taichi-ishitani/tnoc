`ifndef TNOC_BFM_PACKET_AGENT_SVH
`define TNOC_BFM_PACKET_AGENT_SVH

typedef tue_param_agent #(
  .CONFIGURATION  (tnoc_bfm_configuration     ),
  .STATUS         (tnoc_bfm_status            ),
  .SEQUENCER      (tnoc_bfm_packet_sequencer  ),
  .DRIVER         (tnoc_bfm_packet_driver     )
) tnoc_bfm_packet_agent_base;

class tnoc_bfm_packet_agent extends tnoc_bfm_packet_agent_base;
  uvm_analysis_port #(tnoc_bfm_packet_item) tx_packet_port;
  uvm_analysis_port #(tnoc_bfm_packet_item) rx_packet_port;

  tnoc_bfm_packet_tx_monitor  tx_monitor;
  tnoc_bfm_packet_rx_monitor  rx_monitor;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    tx_packet_port  = new("tx_packet_port", this);
    tx_monitor      = tnoc_bfm_packet_tx_monitor::type_id::create("tx_monitor", this);
    tx_monitor.set_context(configuration, status);

    rx_packet_port  = new("rx_packet_port", this);
    rx_monitor      = tnoc_bfm_packet_rx_monitor::type_id::create("rx_monitor", this);
    rx_monitor.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tx_monitor.item_port.connect(tx_packet_port);
    rx_monitor.item_port.connect(rx_packet_port);
    if (is_active_agent()) begin
      rx_monitor.item_port.connect(sequencer.rx_packet_export);
    end
  endfunction

  `tue_component_default_constructor(tnoc_bfm_packet_agent)
  `uvm_component_utils(tnoc_bfm_packet_agent)
endclass
`endif
