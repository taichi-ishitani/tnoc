`ifndef TB_ENV_SVH
`define TB_ENV_SVH
class noc_router_env extends tue_env #(noc_router_env_configuration);
  noc_bfm_packet_agent      bfm_agent[5];
  noc_router_env_sequencer  sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    foreach (bfm_agent[i]) begin
      bfm_agent[i]  = noc_bfm_packet_agent::type_id::create($sformatf("bfm_agent[%0d]", i), this);
      bfm_agent[i].set_configuration(configuration.bfm_cfg[i]);
    end

    sequencer = noc_router_env_sequencer::type_id::create("sequencer", this);
    sequencer.set_configuration(configuration);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    foreach (bfm_agent[i]) begin
      sequencer.bfm_sequencer[i] = bfm_agent[i].sequencer;
    end
  endfunction

  `tue_component_default_constructor(noc_router_env)
  `uvm_component_utils(noc_router_env)
endclass
`endif
