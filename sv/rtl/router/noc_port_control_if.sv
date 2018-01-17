`ifndef NOC_PORT_CONTROL_IF_SV
`define NOC_PORT_CONTROL_IF_SV
interface noc_port_control_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)();
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  logic [CHANNELS-1:0]  request;
  logic [CHANNELS-1:0]  grant;
  logic [CHANNELS-1:0]  free;
  logic [CHANNELS-1:0]  start_of_packet;
  logic [CHANNELS-1:0]  end_of_packet;

  modport requester (
    output  request,
    input   grant,
    output  free,
    output  start_of_packet,
    output  end_of_packet
  );

  modport arbitrator (
    input   request,
    output  grant,
    input   free,
    input   start_of_packet,
    input   end_of_packet
  );
endinterface
`endif
