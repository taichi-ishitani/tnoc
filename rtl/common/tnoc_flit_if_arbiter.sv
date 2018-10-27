module tnoc_flit_if_arbiter
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int             ENTRIES   = 2,
  parameter int             CHANNELS  = CONFIG.virtual_channels,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if[ENTRIES],
  tnoc_flit_if.initiator  flit_out_if
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_flit_utils.svh"

  localparam  int IF_CHANNELS   =
    (is_local_port(PORT_TYPE)) ? 1        : CHANNELS;
  localparam  int IF_ARRAY_SIZE =
    (is_local_port(PORT_TYPE)) ? CHANNELS : 1;

  tnoc_flit_if #(CONFIG, IF_CHANNELS, PORT_TYPE)  flit_in[ENTRIES*IF_ARRAY_SIZE]();
  tnoc_flit_if #(CONFIG, IF_CHANNELS, PORT_TYPE)  flit_out[IF_ARRAY_SIZE]();

//--------------------------------------------------------------
//  Renaming
//--------------------------------------------------------------
  if (is_local_port(PORT_TYPE)) begin : g_rename_local_port
    for (genvar i = 0;i < CHANNELS;++i) begin : g
      for (genvar j = 0;j < ENTRIES;++j) begin : g
        assign  flit_in[ENTRIES*i+j].valid    = flit_in_if[j].valid[i];
        assign  flit_in_if[j].ready[i]        = flit_in[ENTRIES*i+j].ready;
        assign  flit_in[ENTRIES*i+j].flit[0]  = flit_in_if[j].flit[i];
        assign  flit_in_if[j].vc_available[i] = flit_in[ENTRIES*i+j].vc_available;
      end

      assign  flit_out_if.valid[i]      = flit_out[i].valid;
      assign  flit_out[i].ready         = flit_out_if.ready[i];
      assign  flit_out_if.flit[i]       = flit_out[i].flit[0];
      assign  flit_out[i].vc_available  = flit_out_if.vc_available[i];
    end
  end
  else begin : g_rename_internal_port
    `tnoc_flit_array_if_renamer(flit_in_if, flit_in, ENTRIES)
    `tnoc_flit_if_renamer(flit_out[0], flit_out_if)
  end

//--------------------------------------------------------------
//  Arbitration
//--------------------------------------------------------------
  for (genvar i = 0;i < IF_ARRAY_SIZE;++i) begin : g_arbiter
    logic [ENTRIES-1:0] request;
    logic [ENTRIES-1:0] grant;
    logic [ENTRIES-1:0] free;

    for (genvar j = 0;j < ENTRIES;++j) begin : g
      localparam  int IF_INDEX  = ENTRIES*i+j;
      assign  request[j]  = ((flit_in[IF_INDEX].valid           != '0) && is_head_flit(flit_in[IF_INDEX].flit[0])) ? '1 : '0;
      assign  free[j]     = ((flit_in[IF_INDEX].acknowledgement != '0) && is_tail_flit(flit_in[IF_INDEX].flit[0])) ? '1 : '0;
    end

    tbcm_round_robin_arbiter #(
      .REQUESTS     (ENTRIES  ),
      .KEEP_RESULT  (1        )
    ) u_arbiter (
      .clk        (clk      ),
      .rst_n      (rst_n    ),
      .i_request  (request  ),
      .o_grant    (grant    ),
      .i_free     (free     )
    );

    tnoc_flit_if_mux #(
      .CONFIG     (CONFIG       ),
      .CHANNELS   (IF_CHANNELS  ),
      .ENTRIES    (ENTRIES      ),
      .PORT_TYPE  (PORT_TYPE    )
    ) u_mux (
      .i_select     (grant                                    ),
      .flit_in_if   (`tnoc_array_slicer(flit_in, i, ENTRIES)  ),
      .flit_out_if  (flit_out[i]                              )
    );
  end
endmodule
