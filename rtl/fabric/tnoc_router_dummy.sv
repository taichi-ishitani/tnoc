module tnoc_router_dummy
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  tnoc_flit_if_dummy_target #(
    .CONFIG               (CONFIG     ),
    .DEFAULT_READY        ('1         ),
    .DEFAULT_VC_AVAILABLE ('1         ),
    .PORT_TYPE            (PORT_TYPE  )
  ) u_dummy_target (
    flit_in_if
  );
  tnoc_flit_if_dummy_initiator #(
    .CONFIG     (CONFIG     ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_dummy_initiator (
    flit_out_if
  );
endmodule
