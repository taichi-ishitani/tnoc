module noc_vc_mux
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic [CHANNELS-1:0]  i_vc_grant,
  noc_flit_if.target          flit_in_if[CHANNELS],
  noc_flit_if.initiator       flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [FLIT_WIDTH-1:0]  flit_in[CHANNELS];

  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  flit_out_if.valid[i]        = (i_vc_grant[i]) ? flit_in_if[i].valid         : '0;
    assign  flit_in_if[i].ready         = (i_vc_grant[i]) ? flit_out_if.ready[i]        : '0;
    assign  flit_in_if[i].vc_available  = (i_vc_grant[i]) ? flit_out_if.vc_available[i] : '0;
    assign  flit_in[i]                  = flit_in_if[i].flit;
  end endgenerate

  noc_mux #(
    .WIDTH     (FLIT_WIDTH  ),
    .ENTRIES   (CHANNELS    )
  ) noc_mux (
    .i_select  (i_vc_grant        ),
    .i_value   (flit_in           ),
    .o_value   (flit_out_if.flit  )
  );
endmodule
