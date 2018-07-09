module tnoc_flit_if_demux
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels,
  parameter int         ENTRIES   = 2
)(
  input logic [ENTRIES-1:0] i_select,
  tnoc_flit_if.target       flit_in_if,
  tnoc_flit_if.initiator    flit_out_if[ENTRIES]
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  logic [CHANNELS-1:0]  valid[ENTRIES];
  logic [CHANNELS-1:0]  ready[ENTRIES];
  logic [CHANNELS-1:0]  vc_available[ENTRIES];

  for (genvar i = 0;i < ENTRIES;++i) begin
    assign  flit_out_if[i].valid  = valid[i];
    assign  ready[i]              = flit_out_if[i].ready;
    assign  flit_out_if[i].flit   = flit_in_if.flit;
    assign  vc_available[i]       = flit_out_if[i].vc_available;
  end

  tnoc_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_valid_demux (
    .i_select (i_select         ),
    .i_value  (flit_in_if.valid ),
    .o_value  (valid            )
  );

  tnoc_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_raedy_mux (
    .i_select (i_select         ),
    .i_value  (ready            ),
    .o_value  (flit_in_if.ready )
  );

  tnoc_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_vc_available_mux (
    .i_select (i_select                 ),
    .i_value  (vc_available             ),
    .o_value  (flit_in_if.vc_available  )
  );
endmodule
