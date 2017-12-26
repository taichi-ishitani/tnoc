`ifndef NOC_FABRIC_TEST_BASE_SVH
`define NOC_FABRIC_TEST_BASE_SVH
class noc_fabric_test_base extends noc_test_base #(
  .CONFIGURATION  (noc_fabric_env_configuration ),
  .ENV            (noc_fabric_env               ),
  .SEQUENCER      (noc_fabric_env_sequencer     )
);
  `tue_component_default_constructor(noc_fabric_test_base)
endclass

class noc_fabric_test_sequence_base extends noc_sequence_base #(
  noc_fabric_env_sequencer, noc_fabric_env_configuration
);
  `tue_object_default_constructor (noc_fabric_test_sequence_base)
endclass
`endif
