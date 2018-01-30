module tnoc_flit_if_mux
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels,
  parameter int         ENTRIES   = 2
)(
  input logic [ENTRIES-1:0] i_select,
  tnoc_flit_if.target       flit_in_if[ENTRIES],
  tnoc_flit_if.initiator    flit_out_if
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  logic [CHANNELS-1:0]    valid[ENTRIES];
  logic [CHANNELS-1:0]    ready[ENTRIES];
  logic [FLIT_WIDTH-1:0]  flit[ENTRIES];
  logic [CHANNELS-1:0]    vc_available[ENTRIES];

  generate for (genvar i = 0;i < ENTRIES;++i) begin
    assign  valid[i]                    = flit_in_if[i].valid;
    assign  flit_in_if[i].ready         = ready[i];
    assign  flit[i]                     = flit_in_if[i].flit;
    assign  flit_in_if[i].vc_available  = vc_available[i];
  end endgenerate

  tnoc_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_valid_mux (
    .i_select (i_select           ),
    .i_value  (valid              ),
    .o_value  (flit_out_if.valid  )
  );

  tnoc_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_ready_demux (
    .i_select (i_select           ),
    .i_value  (flit_out_if.ready  ),
    .o_value  (ready              )
  );

  tnoc_mux #(
    .WIDTH    (FLIT_WIDTH ),
    .ENTRIES  (ENTRIES    )
  ) u_flit_mux (
    .i_select (i_select           ),
    .i_value  (flit               ),
    .o_value  (flit_out_if.flit   )
  );

  tnoc_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_vc_available_demux (
    .i_select (i_select                 ),
    .i_value  (flit_out_if.vc_available ),
    .o_value  (vc_available             )
  );
endmodule
