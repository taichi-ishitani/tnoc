module tnoc_flit_if_dummy_initiator
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int             CHANNELS  = CONFIG.virtual_channels,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  tnoc_flit_if.initiator  flit_if
);
  localparam  int FLITS = (is_local_port(PORT_TYPE)) ? CHANNELS : 1;
  assign  flit_if.valid = '0;
  for (genvar i = 0;i < FLITS;++i) begin
    assign  flit_if.flit[i] = '0;
  end
endmodule
