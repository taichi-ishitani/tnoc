module tnoc_input_fifo
  import  tnoc_config_pkg::*;
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic                 clk,
  input   logic                 rst_n,
  input   logic                 i_clear,
  output  logic [CHANNELS-1:0]  o_empty,
  output  logic [CHANNELS-1:0]  o_almost_full,
  output  logic [CHANNELS-1:0]  o_full,
  tnoc_flit_if.target           flit_in_if,
  tnoc_flit_if.initiator        flit_out_if[CHANNELS]
);
  localparam  int DEPTH     = CONFIG.input_fifo_depth;
  localparam  int THRESHOLD = DEPTH - 2;

  tnoc_flit_if #(CONFIG, 1) flit_if[CHANNELS]();

  tnoc_vc_demux #(
    .CONFIG (CONFIG )
  ) u_vc_demux (
    .flit_in_if   (flit_in_if ),
    .flit_out_if  (flit_if    )
  );

  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_fifo
    tnoc_flit_if_fifo #(
      .CONFIG     (CONFIG     ),
      .CHANNELS   (1          ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  ),
      .FIFO_MEM   (1          )
    ) u_fifo (
      .clk            (clk              ),
      .rst_n          (rst_n            ),
      .i_clear        (i_clear          ),
      .o_empty        (o_empty[i]       ),
      .o_almost_full  (o_almost_full[i] ),
      .o_full         (o_full[i]        ),
      .flit_in_if     (flit_if[i]       ),
      .flit_out_if    (flit_out_if[i]   )
    );
  end endgenerate
endmodule
