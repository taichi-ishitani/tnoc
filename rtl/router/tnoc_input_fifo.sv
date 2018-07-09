module tnoc_input_fifo
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter   tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT,
  localparam  int             CHANNELS  = CONFIG.virtual_channels
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
  `include  "tnoc_macros.svh"

  localparam  int DEPTH     = CONFIG.input_fifo_depth;
  localparam  int THRESHOLD = DEPTH - 2;

  `tnoc_internal_flit_if(1) flit_if[CHANNELS]();

  tnoc_vc_demux #(
    .CONFIG     (CONFIG     ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_vc_demux (
    .flit_in_if   (flit_in_if ),
    .flit_out_if  (flit_if    )
  );

  for (genvar i = 0;i < CHANNELS;++i) begin : g_fifo
    tnoc_flit_if_fifo #(
      .CONFIG     (CONFIG     ),
      .CHANNELS   (1          ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  ),
      .FIFO_MEM   (1          ),
      .PORT_TYPE  (PORT_TYPE  )
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
  end
endmodule
