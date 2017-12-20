module noc_flit_channe_merger
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic                 clk,
  input logic                 rst_n,
  noc_flit_channel_if.target  flit_in_if[CHANNELS],
  noc_flit_if.initiator       flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]  request;
  logic [CHANNELS-1:0]  grant;
  logic [CHANNELS-1:0]  valid;
  noc_flit              flit_in[CHANNELS];
  noc_flit              flit_out;
  noc_flit              flit;
  genvar                g_i;

//--------------------------------------------------------------
//  Channel Arbitration/Flit Selection
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin
    assign  request[g_i]          = (flit_in_if[g_i].valid && flit_out_if.ready[g_i]) ? '1 : '0;
    assign  flit_in[g_i]          = flit_in_if[g_i].flit;
    assign  flit_in_if[g_i].ready = grant[g_i];
  end endgenerate

  noc_round_robin_arbiter #(
    .REQUESTS     (CHANNELS ),
    .KEEP_RESULT  (0        )
  ) u_channel_arbiter (
    .clk        (clk      ),
    .rst_n      (rst_n    ),
    .i_request  (request  ),
    .o_grant    (grant    ),
    .i_free     ('0       )
  );

  noc_mux #(
    .WIDTH     (FLIT_WIDTH    ),
    .ENTRIES   (CHANNELS      )
  ) u_flit_mux (
    .i_select (grant    ),
    .i_value  (flit_in  ),
    .o_value  (flit_out )
  );

//--------------------------------------------------------------
//  Output
//--------------------------------------------------------------
  assign  flit_out_if.valid = valid;
  assign  flit_out_if.flit  = flit;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      valid <= '0;
      flit  <= '0;
    end
    else if (
      (valid == '0) || ((valid & flit_out_if.ready) != '0)
    ) begin
      valid <= grant;
      flit  <= flit_out;
    end
  end
endmodule
