`ifndef NOC_TEST_BASE_SVH
`define NOC_TEST_BASE_SVH
class noc_test_base #(
  type  CONFIGURATION = tue_configuration_dummy,
  type  STATUS        = tue_status_dummy,
  type  ENV           = tue_env #(CONFIGURATION, STATUS),
  type  SEQUENCER     = uvm_sequencer_base
) extends tue_test #(CONFIGURATION, STATUS);
  ENV       env;
  SEQUENCER sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ENV::type_id::create("env", this);
    env.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sequencer = env.sequencer;
  endfunction

  function void create_configuration();
    void'(uvm_config_db #(CONFIGURATION)::get(
      null, "", "configuration", configuration
    ));
  endfunction

  function void set_default_sequence(
    uvm_sequencer_base  sequencer,
    string              phase,
    uvm_object_wrapper  default_sequence
  );
    uvm_config_db #(uvm_object_wrapper)::set(
      sequencer, phase, "default_sequence", default_sequence
    );
  endfunction

  `tue_component_default_constructor(noc_test_base)
endclass
`endif
