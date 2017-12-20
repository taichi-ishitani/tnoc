`ifndef NOC_FLIT_BUS_IF_SV
`define NOC_FLIT_BUS_IF_SV
interface noc_flit_bus_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)();
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]  valid;
  logic [CHANNELS-1:0]  ready;
  noc_flit              flit[CHANNELS];

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
    genvar  g_i;
    generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_debug
      noc_flit          flit_debug;
      noc_common_header header;

      assign  flit_debug  = flit[g_i];
      assign  header       = (is_header_flit(flit_debug)) ? get_common_header(flit_debug) : '0;
    end endgenerate
  `endif
endinterface
`endif
