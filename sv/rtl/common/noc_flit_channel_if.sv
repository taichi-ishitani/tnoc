`ifndef NOC_FLIT_CHANNEL_IF_SV
`define NOC_FLIT_CHANNEL_IF_SV
interface noc_flit_channel_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)();
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic     valid;
  logic     ready;
  noc_flit  flit;

  modport initiator(
    output  valid,
    input   ready,
    output  flit
  );

  modport target(
    input   valid,
    output  ready,
    input   flit
  );

  modport monitor(
    input valid,
    input ready,
    input flit
  );

  `ifndef SYNTHESIS
    `include  "noc_flit_utils.svh"
    noc_common_header header;
    assign  header  = (is_header_flit(flit)) ? get_common_header(flit) : '0;
  `endif
endinterface
`endif
