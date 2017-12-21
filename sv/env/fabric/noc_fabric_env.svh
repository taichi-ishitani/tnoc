`ifndef NOC_FABRIC_ENV_SVH
`define NOC_FABRIC_ENV_SVH
class noc_fabric_env extends tue_env #(noc_fabric_env_configuration);
  noc_bfm_packet_agent      bfm_agent[int][int];
  noc_fabric_env_sequencer  sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    for (int y = 0;y < configuration.size_y;++y) begin
      for (int x = 0;x < configuration.size_x;++x) begin
        bfm_agent[y][x] = noc_bfm_packet_agent::type_id::create($sformatf("bfm_agent[%d][%0d]", y, x), this);
        bfm_agent[y][x].set_configuration(configuration.bfm_cfg[configuration.size_x*y+x]);
      end
    end

    sequencer = noc_fabric_env_sequencer::type_id::create("sequencer", this);
    sequencer.set_configuration(configuration);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    foreach (bfm_agent[y, x]) begin
      sequencer.bfm_sequencer[y][x] = bfm_agent[y][x].sequencer;
    end
  endfunction

  `tue_component_default_constructor(noc_fabric_env)
  `uvm_component_utils(noc_fabric_env)
endclass
`endif
