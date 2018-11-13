module tnoc_output_block_dummy
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)(
  tnoc_flit_if.target             flit_in_if[5],
  tnoc_flit_if.initiator          flit_out_if,
  tnoc_port_control_if.arbitrator port_control_if[5]
);
  for (genvar i = 0;i < 5;++i) begin : g_dummy_target
    tnoc_flit_if_dummy_target #(
      .CONFIG     (CONFIG             ),
      .PORT_TYPE  (TNOC_INTERNAL_PORT )
    ) u_dummy_target (
      flit_in_if[i]
    );
  end

  tnoc_flit_if_dummy_initiator #(
    .CONFIG     (CONFIG             ),
    .PORT_TYPE  (TNOC_INTERNAL_PORT )
  ) u_dummy_initiator (
    flit_out_if
  );

  for (genvar i = 0;i < 5;++i) begin
    assign  port_control_if[i].grant  = '0;
  end
endmodule
