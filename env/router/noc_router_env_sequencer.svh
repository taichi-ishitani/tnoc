`ifndef NOC_ROUTER_ENV_SEQUENCER_SVH
`define NOC_ROUTER_ENV_SEQUENCER_SVH
class noc_router_env_sequencer extends tue_sequencer #(noc_router_env_configuration);
  noc_bfm_packet_sequencer  bfm_sequencer[5];
  `tue_component_default_constructor(noc_router_env_sequencer)
  `uvm_component_utils(noc_router_env_sequencer)
endclass
`endif
