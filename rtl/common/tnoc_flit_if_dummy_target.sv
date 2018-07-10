module tnoc_flit_if_dummy_target
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config         CONFIG                = TNOC_DEFAULT_CONFIG,
  parameter int                 CHANNELS              = CONFIG.virtual_channels,
  parameter bit [CHANNELS-1:0]  DEFAULT_READY         = '0,
  parameter bit [CHANNELS-1:0]  DEFAULT_VC_AVAILABLE  = '0,
  parameter tnoc_port_type      PORT_TYPE             = TNOC_LOCAL_PORT
)(
  tnoc_flit_if.target flit_if
);
  assign  flit_if.ready         = DEFAULT_READY;
  assign  flit_if.vc_available  = DEFAULT_VC_AVAILABLE;
endmodule
