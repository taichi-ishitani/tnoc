module tnoc_vc_mux
  import  tnoc_config_pkg::*;
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic [CHANNELS-1:0]  i_vc_grant,
  tnoc_flit_if.target         flit_in_if[CHANNELS],
  tnoc_flit_if.initiator      flit_out_if
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  logic [FLIT_WIDTH-1:0]  flit_in[CHANNELS];

  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  flit_out_if.valid[i]        = (i_vc_grant[i]) ? flit_in_if[i].valid         : '0;
    assign  flit_in_if[i].ready         = (i_vc_grant[i]) ? flit_out_if.ready[i]        : '0;
    assign  flit_in_if[i].vc_available  = (i_vc_grant[i]) ? flit_out_if.vc_available[i] : '0;
    assign  flit_in[i]                  = flit_in_if[i].flit;
  end endgenerate

  tnoc_mux #(
    .WIDTH     (FLIT_WIDTH  ),
    .ENTRIES   (CHANNELS    )
  ) ttnoc_mux (
    .i_select  (i_vc_grant        ),
    .i_value   (flit_in           ),
    .o_value   (flit_out_if.flit  )
  );
endmodule
