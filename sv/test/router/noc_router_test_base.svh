`ifndef noc_router_test_base_svh
class noc_router_test_base extends tue_test #(noc_bfm_configuration, noc_bfm_status);
  noc_bfm_packet_sequencer  packet_sequencer;
  noc_bfm_packet_agent      packet_agent;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet_agent  = noc_bfm_packet_agent::type_id::create("packet_agent", this);
    packet_agent.set_configuration(configuration);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    packet_sequencer  = packet_agent.sequencer;
  endfunction

  function void create_configuration();
    void'(uvm_config_db #(noc_bfm_configuration)::get(
      null, "", "configuration", configuration
    ));
  endfunction

  `tue_component_default_constructor(noc_router_test_base)
endclass

class noc_router_test_sequence_base extends tue_sequence #(
  noc_bfm_configuration, noc_bfm_status
);
  function new(string name = "noc_router_test_sequence_base");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  `uvm_declare_p_sequencer(noc_bfm_packet_sequencer)
endclass
`endif
