module noc_flit_channel_mux
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG      = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS    = 5,
  parameter int         FIFO_DEPTH  = 0
)(
  input logic                   clk,
  input logic                   rst_n,
  input logic [CHANNELS-1:0]    i_select,
  noc_flit_channel_if.target    flit_in_if[CHANNELS],
  noc_flit_channel_if.initiator flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]        valid_in;
  logic                       valid_out;
  logic                       ready_in;
  logic [$bits(noc_flit)-1:0] flit_in[CHANNELS];
  logic [$bits(noc_flit)-1:0] flit_out;
  genvar                      g_i;

  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin
    assign  valid_in[g_i]         = flit_in_if[g_i].valid;
    assign  flit_in[g_i]          = flit_in_if[g_i].flit;
    assign  flit_in_if[g_i].ready = (i_select[g_i]) ? ready_in : '0;
  end endgenerate

  assign  valid_out = |(valid_in & i_select);

  noc_mux #(FLIT_WIDTH, CHANNELS) u_flit_mux (
    .i_select (i_select ),
    .i_value  (flit_in  ),
    .o_value  (flit_out )
  );

  generate if (FIFO_DEPTH > 0) begin : g_fifo
    noc_flit_channel_if #(CONFIG) fifo_in_if();

    assign  fifo_in_if.valid  = valid_out;
    assign  ready_in          = fifo_in_if.ready;
    assign  fifo_in_if.flit   = flit_out;

    noc_flit_channel_fifo #(
      .CONFIG (CONFIG     ),
      .DEPTH  (FIFO_DEPTH )
    ) u_fifo (
      .clk          (clk          ),
      .rst_n        (rst_n        ),
      .i_clear      ('0           ),
      .o_empty      (),
      .o_full       (),
      .flit_in_if   (fifo_in_if   ),
      .flit_out_if  (flit_out_if  )
    );
  end
  else begin : g_no_fifo
    assign  flit_out_if.valid = valid_out;
    assign  ready_in          = flit_out_if.ready;
    assign  flit_out_if.flit  = flit_out;
  end endgenerate
endmodule
