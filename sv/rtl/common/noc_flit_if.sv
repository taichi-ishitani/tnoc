`ifndef NOC_FLIT_IF_SV
`define NOC_FLIT_IF_SV
interface noc_flit_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels
)();
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]  valid;
  logic [CHANNELS-1:0]  ready;
  noc_flit              flit;
  logic [CHANNELS-1:0]  vc_available;

  modport initiator (
    output  valid,
    input   ready,
    output  flit,
    input   vc_available
  );

  modport target (
    input   valid,
    output  ready,
    input   flit,
    output  vc_available
  );

  modport monitor (
    input valid,
    input ready,
    input flit,
    input vc_available
  );

  `ifndef SYNTHESIS
    `include  "noc_flit_utils.svh"
    generate for (genvar i = 0;i < CHANNELS;++i) begin : g_debug
      noc_common_header header  = '0;
      always @* begin
        if (valid[i] && ready[i] && is_header_flit(flit)) begin
          header  = get_common_header(flit);
        end
      end
    end endgenerate
  `endif
endinterface
`endif
