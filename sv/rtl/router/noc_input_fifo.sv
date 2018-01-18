module noc_input_fifo
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic                 clk,
  input   logic                 rst_n,
  input   logic                 i_clear,
  output  logic [CHANNELS-1:0]  o_empty,
  output  logic [CHANNELS-1:0]  o_almost_full,
  output  logic [CHANNELS-1:0]  o_full,
  noc_flit_if.target            flit_in_if,
  noc_flit_if.initiator         flit_out_if[CHANNELS]
);
  localparam  int DEPTH     = CONFIG.input_fifo_depth;
  localparam  int THRESHOLD = DEPTH - 2;

  noc_flit_if #(CONFIG, 1)  flit_if[CHANNELS]();

  noc_vc_demux #(
    .CONFIG (CONFIG )
  ) u_vc_demux (
    .flit_in_if   (flit_in_if ),
    .flit_out_if  (flit_if    )
  );

  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_fifo
    noc_flit_if_fifo #(
      .CONFIG     (CONFIG     ),
      .CHANNELS   (1          ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  )
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
