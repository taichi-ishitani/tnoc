`ifndef NOC_PORT_CONTROL_IF_SV
`define NOC_PORT_CONTROL_IF_SV
interface noc_port_control_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)();
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  logic [CHANNELS-1:0]  port_request;
  logic [CHANNELS-1:0]  port_grant;
  logic [CHANNELS-1:0]  port_free;
  logic [CHANNELS-1:0]  vc_request;
  logic [CHANNELS-1:0]  vc_grant;
  logic [CHANNELS-1:0]  vc_free;

  modport requester (
    output  port_request,
    input   port_grant,
    output  port_free,
    output  vc_request,
    input   vc_grant,
    output  vc_free
  );

  modport arbitrator (
    input   port_request,
    output  port_grant,
    input   port_free,
    input   vc_request,
    output  vc_grant,
    input   vc_free
  );
endinterface
`endif
