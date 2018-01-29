module noc_flit_if_demux
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels,
  parameter int         ENTRIES   = 2
)(
  input logic [ENTRIES-1:0] i_select,
  noc_flit_if.target        flit_in_if,
  noc_flit_if.initiator     flit_out_if[ENTRIES]
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]    valid[ENTRIES];
  logic [CHANNELS-1:0]    ready[ENTRIES];
  logic [FLIT_WIDTH-1:0]  flit[ENTRIES];
  logic [CHANNELS-1:0]    vc_available[ENTRIES];

  generate for (genvar i = 0;i < ENTRIES;++i) begin
    assign  flit_out_if[i].valid  = valid[i];
    assign  ready[i]              = flit_out_if[i].ready;
    assign  flit_out_if[i].flit   = flit[i];
    assign  vc_available[i]       = flit_out_if[i].vc_available;
  end endgenerate

  noc_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_valid_demux (
    .i_select (i_select         ),
    .i_value  (flit_in_if.valid ),
    .o_value  (valid            )
  );

  noc_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_valid_mux (
    .i_select (i_select         ),
    .i_value  (ready            ),
    .o_value  (flit_in_if.ready )
  );

  noc_demux #(
    .WIDTH    (FLIT_WIDTH ),
    .ENTRIES  (ENTRIES    )
  ) u_flit_demux (
    .i_select (i_select         ),
    .i_value  (flit_in_if.flit  ),
    .o_value  (flit             )
  );

  noc_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  )
  ) u_vc_available_mux (
    .i_select (i_select                 ),
    .i_value  (vc_available             ),
    .o_value  (flit_in_if.vc_available  )
  );
endmodule
