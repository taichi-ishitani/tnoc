module noc_flit_if_fifo
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels,
  parameter int         DEPTH     = 8,
  parameter int         THRESHOLD = DEPTH,
  parameter bit         FIFO_MEM  = 0
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

  logic empty;
  logic almost_full;
  logic full;

  assign  o_empty                 = empty;
  assign  o_almost_full           = almost_full;
  assign  o_full                  = full;
  assign  flit_in_if.ready        = {CHANNELS{~full       }};
  assign  flit_in_if.vc_available = {CHANNELS{~almost_full}};

  generate if (CHANNELS == 0) begin : g_channels_eq_0
    assign  flit_out_if.valid = ~empty;

    noc_fifo #(
      .WIDTH      (FLIT_WIDTH ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  ),
      .FIFO_MEM   (FIFO_MEM   )
    ) u_fifo (
      .clk            (clk                ),
      .rst_n          (rst_n              ),
      .i_clear        (i_clear            ),
      .o_empty        (empty              ),
      .o_full         (full               ),
      .o_almost_full  (almost_full        ),
      .i_push         (flit_in_if.valid   ),
      .i_data         (flit_in_if.flit    ),
      .i_pop          (flit_out_if.ready  ),
      .o_data         (flit_out_if.flit   )
    );
  end
  else begin : g_channels_gt_0
    localparam  int FIFO_WIDTH  = $bits(s_fifo_data);

    logic       push;
    s_fifo_data data_in;
    logic       pop;
    s_fifo_data data_out;

    assign  flit_out_if.valid = (!empty) ? data_out.valid : '0;
    assign  flit_out_if.flit  = data_out.flit;

    assign  push          = |flit_in_if.valid;
    assign  pop           = |(flit_out_if.valid & flit_out_if.ready);
    assign  data_in.valid = flit_in_if.valid;
    assign  data_in.flit  = flit_in_if.flit;

    noc_fifo #(
      .WIDTH      (FIFO_WIDTH ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  ),
      .FIFO_MEM   (FIFO_MEM   )
    ) u_fifo (
      .clk            (clk          ),
      .rst_n          (rst_n        ),
      .i_clear        (i_clear      ),
      .o_empty        (empty        ),
      .o_full         (full         ),
      .o_almost_full  (almost_full  ),
      .i_push         (push         ),
      .i_data         (data_in      ),
      .i_pop          (pop          ),
      .o_data         (data_out     )
    );
  end endgenerate
endmodule
