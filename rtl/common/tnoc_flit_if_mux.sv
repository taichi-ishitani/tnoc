module tnoc_flit_if_mux
  `include  "tnoc_default_imports.svh"
#(
  parameter
    tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
    int             CHANNELS  = CONFIG.virtual_channels,
    int             ENTRIES   = 2,
    tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  input logic [ENTRIES-1:0] i_select,
  tnoc_flit_if.target       flit_in_if[ENTRIES],
  tnoc_flit_if.initiator    flit_out_if
);
  `include  "tnoc_packet_flit_macros.svh"
  `tnoc_define_packet_and_flit(CONFIG)

//--------------------------------------------------------------
//  Control signals
//--------------------------------------------------------------
  logic [CHANNELS-1:0]  valid[ENTRIES];
  logic [CHANNELS-1:0]  ready[ENTRIES];
  logic [CHANNELS-1:0]  vc_available[ENTRIES];


  for (genvar i = 0;i < ENTRIES;++i) begin
    assign  valid[i]                    = flit_in_if[i].valid;
    assign  flit_in_if[i].ready         = ready[i];
    assign  flit_in_if[i].vc_available  = vc_available[i];
  end

  tbcm_mux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  ),
    .ONE_HOT  (1        )
  ) u_valid_mux (
    .i_select (i_select           ),
    .i_data   (valid              ),
    .o_data   (flit_out_if.valid  )
  );

  tbcm_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  ),
    .ONE_HOT  (1        )
  ) u_ready_demux (
    .i_select (i_select           ),
    .i_data   (flit_out_if.ready  ),
    .o_data   (ready              )
  );

  tbcm_demux #(
    .WIDTH    (CHANNELS ),
    .ENTRIES  (ENTRIES  ),
    .ONE_HOT  (1        )
  ) u_vc_available_demux (
    .i_select (i_select                 ),
    .i_data   (flit_out_if.vc_available ),
    .o_data   (vc_available             )
  );

//--------------------------------------------------------------
//  Flit
//--------------------------------------------------------------
  localparam  int FLITS = (is_local_port(PORT_TYPE)) ? CHANNELS : 1;

  for (genvar i = 0;i < FLITS;++i) begin : g_flit_mux
    tnoc_flit flit_in[ENTRIES];

    for (genvar j = 0;j < ENTRIES;++j) begin
      assign  flit_in[j]  = flit_in_if[j].flit[i];
    end

    tbcm_mux #(
      .DATA_TYPE  (tnoc_flit  ),
      .ENTRIES    (ENTRIES    ),
      .ONE_HOT    (1          )
    ) u_flit_mux (
      .i_select (i_select             ),
      .i_data   (flit_in              ),
      .o_data   (flit_out_if.flit[i]  )
    );
  end
endmodule
