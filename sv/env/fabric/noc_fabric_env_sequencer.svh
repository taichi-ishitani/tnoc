`ifndef NOC_FABRIC_ENV_SEQUENCER_SVH
`define NOC_FABRIC_ENV_SEQUENCER_SVH
class noc_fabric_env_sequencer extends tue_sequencer #(noc_fabric_env_configuration);
  noc_bfm_packet_sequencer  bfm_sequencer[int][int];
  `tue_component_default_constructor(noc_fabric_env_sequencer)
  `uvm_component_utils(noc_fabric_env_sequencer)
endclass
`endif
