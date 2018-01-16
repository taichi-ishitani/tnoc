module noc_flit_if_fifo
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels,
  parameter int         DEPTH     = 8,
  parameter int         THRESHOLD = DEPTH - 1
)(
  input   logic         clk,
  input   logic         rst_n,
  input   logic         i_clear,
  output  logic         o_empty,
  output  logic         o_almost_full,
  output  logic         o_full,
  noc_flit_if.target    flit_in_if,
  noc_flit_if.initiator flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  typedef struct packed {
    logic [CHANNELS-1:0]    valid;
    logic [FLIT_WIDTH-1:0]  flit;
  } s_fifo_data;

  logic almost_full;
  assign  o_almost_full           = almost_full;
  assign  flit_in_if.vc_available = {CHANNELS{~almost_full}};

  generate if (CHANNELS == 0) begin : g_channels_eq_0
    noc_fifo #(
      .WIDTH      (FLIT_WIDTH ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  )
    ) u_fifo (
      .clk            (clk                ),
      .rst_n          (rst_n              ),
      .i_clear        (i_clear            ),
      .o_empty        (o_empty            ),
      .o_full         (o_full             ),
      .o_almost_full  (almost_full        ),
      .i_valid        (flit_in_if.valid   ),
      .o_ready        (flit_in_if.ready   ),
      .i_data         (flit_in_if.flit    ),
      .o_valid        (flit_out_if.valid  ),
      .i_ready        (flit_out_if.ready  ),
      .o_data         (flit_out_if.flit   )
    );
  end
  else begin : g_channels_gt_0
    localparam  int FIFO_WIDTH  = $bits(s_fifo_data);

    logic       valid_in;
    logic       ready_out;
    s_fifo_data data_in;
    logic       valid_out;
    logic       ready_in;
    s_fifo_data data_out;

    noc_fifo #(
      .WIDTH      (FIFO_WIDTH ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  )
    ) u_fifo (
      .clk            (clk          ),
      .rst_n          (rst_n        ),
      .i_clear        (i_clear      ),
      .o_empty        (o_empty      ),
      .o_full         (o_full       ),
      .o_almost_full  (almost_full  ),
      .i_valid        (valid_in     ),
      .o_ready        (ready_out    ),
      .i_data         (data_in      ),
      .o_valid        (valid_out    ),
      .i_ready        (ready_in     ),
      .o_data         (data_out     )
    );

    assign  valid_in          = |flit_in_if.valid;
    assign  flit_in_if.ready  = {CHANNELS{ready_out}};
    assign  data_in.valid     = flit_in_if.valid;
    assign  data_in.flit      = flit_in_if.flit;

    assign  flit_out_if.valid = (valid_out) ? data_out.valid : '0;
    assign  ready_in          = |(flit_out_if.valid & flit_out_if.ready);
    assign  flit_out_if.flit  = data_out.flit;
  end endgenerate
endmodule
