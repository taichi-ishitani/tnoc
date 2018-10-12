module tnoc_vc_mux
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter   tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT,
  localparam  int             CHANNELS  = CONFIG.virtual_channels
)(
  input logic [CHANNELS-1:0]  i_vc_grant,
  tnoc_flit_if.target         flit_in_if[CHANNELS],
  tnoc_flit_if.initiator      flit_out_if
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  if (is_local_port(PORT_TYPE)) begin : g_vc_mux_local_port
    for (genvar i = 0;i < CHANNELS;++i) begin
      assign  flit_out_if.valid[i]        = flit_in_if[i].valid;
      assign  flit_in_if[i].ready         = flit_out_if.ready[i];
      assign  flit_out_if.flit[i]         = flit_in_if[i].flit[0];
      assign  flit_in_if[i].vc_available  = flit_out_if.vc_available[i];
    end
  end
  else begin : g_vc_mux_internal_port
    logic [TNOC_FLIT_WIDTH-1:0] flit_in[CHANNELS];

    for (genvar i = 0;i < CHANNELS;++i) begin
      assign  flit_out_if.valid[i]        = i_vc_grant[i] & flit_in_if[i].valid;
      assign  flit_in_if[i].ready         = i_vc_grant[i] & flit_out_if.ready[i];
      assign  flit_in[i]                  = flit_in_if[i].flit[0];
      assign  flit_in_if[i].vc_available  = flit_out_if.vc_available[i];
    end

    tnoc_mux #(
      .WIDTH     (TNOC_FLIT_WIDTH ),
      .ENTRIES   (CHANNELS        )
    ) ttnoc_mux (
      .i_select  (i_vc_grant          ),
      .i_value   (flit_in             ),
      .o_value   (flit_out_if.flit[0] )
    );
  end
endmodule
