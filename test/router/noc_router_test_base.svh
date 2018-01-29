`ifndef NOC_ROUTER_TEST_BASE_SVH
`define NOC_ROUTER_TEST_BASE_SVH
class noc_router_test_base extends noc_test_base #(
  .CONFIGURATION  (noc_router_env_configuration ),
  .ENV            (noc_router_env               ),
  .SEQUENCER      (noc_router_env_sequencer     )
);
  `tue_component_default_constructor(noc_router_test_base)
endclass

class noc_router_test_sequence_base extends noc_sequence_base #(
  noc_router_env_sequencer, noc_router_env_configuration
);
  `tue_object_default_constructor(noc_router_test_sequence_base)
endclass
`endif
