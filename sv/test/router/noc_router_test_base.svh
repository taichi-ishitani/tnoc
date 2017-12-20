`ifndef noc_router_test_base_svh
class noc_router_test_base extends tue_test #(noc_router_env_configuration);
  noc_router_env            env;
  noc_router_env_sequencer  sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = noc_router_env::type_id::create("env", this);
    env.set_configuration(configuration);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sequencer = env.sequencer;
  endfunction

  function void create_configuration();
    void'(uvm_config_db #(noc_router_env_configuration)::get(
      null, "", "configuration", configuration
    ));
  endfunction

  `tue_component_default_constructor(noc_router_test_base)
endclass

class noc_router_test_sequence_base extends tue_sequence #(
  noc_router_env_configuration
);
  function new(string name = "noc_router_test_sequence_base");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  `uvm_declare_p_sequencer(noc_router_env_sequencer)
endclass
`endif
