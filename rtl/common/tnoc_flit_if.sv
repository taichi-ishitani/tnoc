`ifndef TNOC_FLIT_IF_SV
`define TNOC_FLIT_IF_SV
interface tnoc_flit_if
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int             CHANNELS  = CONFIG.virtual_channels,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)();
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  localparam  int FLITS = (is_local_port(PORT_TYPE)) ? CHANNELS : 1;

  logic [CHANNELS-1:0]  valid;
  logic [CHANNELS-1:0]  ready;
  tnoc_flit             flit[FLITS];
  logic [CHANNELS-1:0]  vc_available;
  logic [CHANNELS-1:0]  acknowledgement;

  assign  acknowledgement = valid & ready;

  modport initiator (
    output  valid,
    input   ready,
    output  flit,
    input   vc_available,
    input   acknowledgement
  );

  modport target (
    input   valid,
    output  ready,
    input   flit,
    output  vc_available,
    input   acknowledgement
  );

  modport monitor (
    input valid,
    input ready,
    input flit,
    input vc_available,
    input acknowledgement
  );

`ifndef SYNTHESIS
  `include  "tnoc_flit_utils.svh"
  for (genvar i = 0;i < CHANNELS;++i) begin : g_debug
    localparam  int FLIT_INDEX  = (is_local_port(PORT_TYPE)) ? i : 0;
    tnoc_common_header  header  = '0;
    always @* begin
      if (acknowledgement[i] && is_header_flit(flit[FLIT_INDEX])) begin
        header  = get_common_header(flit[FLIT_INDEX]);
      end
    end
  end
`endif
endinterface
`endif
