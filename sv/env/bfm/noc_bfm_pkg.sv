`ifndef NOC_BFM_PKG_SV
`define NOC_BFM_PKG_SV
package noc_bfm_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"
  `include  "noc_bfm_macro.svh"

  typedef virtual noc_bfm_flit_if noc_bfm_flit_vif;

  `include  "noc_bfm_configuration.svh"
  `include  "noc_bfm_status.svh"
  `include  "noc_bfm_flit_item.svh"
  `include  "noc_bfm_packet_item.svh"

  `include  "noc_bfm_component_base.svh"
  `include  "noc_bfm_packet_monitor.svh"
  `include  "noc_bfm_packet_sequencer.svh"
  `include  "noc_bfm_packet_driver.svh"
  `include  "noc_bfm_packet_agent.svh"
endpackage
`endif
