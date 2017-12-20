module noc_output_switch
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)(
  input logic             clk,
  input logic             rst_n,
  noc_flit_bus_if.target  flit_in_if_x_plus,
  noc_flit_bus_if.target  flit_in_if_x_minus,
  noc_flit_bus_if.target  flit_in_if_y_plus,
  noc_flit_bus_if.target  flit_in_if_y_minus,
  noc_flit_bus_if.target  flit_in_if_local,
  noc_flit_if.initiator   flit_out_if
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  `include  "noc_packet.svh"
  `include  "noc_flit.svh"
  `include  "noc_flit_utils.svh"

  noc_flit_bus_if #(CONFIG)     flit_in_if[5]();
  noc_flit_channel_if #(CONFIG) flit_out_channel_if[CHANNELS]();

  genvar  g_i;
  genvar  g_j;

//--------------------------------------------------------------
//  Input Interface Renaming
//--------------------------------------------------------------
  noc_flit_bus_renamer u_renamer_flit_in_x_plus (
    flit_in_if_x_plus, flit_in_if[0]
  );
  noc_flit_bus_renamer u_renamer_flit_in_x_minus (
    flit_in_if_x_minus, flit_in_if[1]
  );
  noc_flit_bus_renamer u_renamer_flit_in_y_plus (
    flit_in_if_y_plus, flit_in_if[2]
  );
  noc_flit_bus_renamer u_renamer_flit_in_y_minus (
    flit_in_if_y_minus, flit_in_if[3]
  );
  noc_flit_bus_renamer u_renamer_flit_in_local (
    flit_in_if_local, flit_in_if[4]
  );

//--------------------------------------------------------------
//  Input Selection
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_channel
    noc_flit_channel_if #(CONFIG) flit_in_channel_if[5]();

    for (g_j = 0;g_j < 5;++g_j) begin
      assign  flit_in_channel_if[g_j].valid = flit_in_if[g_j].valid[g_i];
      assign  flit_in_if[g_j].ready[g_i]    = flit_in_channel_if[g_j].ready;
      assign  flit_in_channel_if[g_j].flit  = flit_in_if[g_j].flit[g_i];
    end

    //  Arbitration
    logic [4:0] request;
    logic [4:0] grant;
    logic [4:0] free;

    for (g_j = 0;g_j < 5;++g_j) begin
      assign  request[g_j]  = (
        flit_in_channel_if[g_j].valid && is_header_flit(flit_in_channel_if[g_j].flit)
      ) ? '1 : '0;
      assign  free[g_j] = (
        flit_in_channel_if[g_j].valid && flit_in_channel_if[g_j].ready && is_tail_flit(flit_in_channel_if[g_j].flit)
      ) ? '1 : '0;
    end

    noc_round_robin_arbiter #(5, 1) u_input_arbiter (
      .clk        (clk      ),
      .rst_n      (rst_n    ),
      .i_request  (request  ),
      .o_grant    (grant    ),
      .i_free     (free     )
    );

    //  MUX
    noc_flit_channel_mux #(
      .CONFIG     (CONFIG ),
      .CHANNELS   (5      ),
      .FIFO_DEPTH (2      )
    ) u_input_mux (
      .clk          (clk                      ),
      .rst_n        (rst_n                    ),
      .i_select     (grant                    ),
      .flit_in_if   (flit_in_channel_if       ),
      .flit_out_if  (flit_out_channel_if[g_i] )
    );
  end endgenerate

//--------------------------------------------------------------
//  Merge Channels
//--------------------------------------------------------------
  noc_flit_channe_merger #(
    .CONFIG (CONFIG )
  ) u_channe_merger (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .flit_in_if   (flit_out_channel_if  ),
    .flit_out_if  (flit_out_if          )
  );
endmodule
