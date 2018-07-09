module tnoc_vc_selector
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter tnoc_port_type  PORT_TYPE       = TNOC_LOCAL_PORT,
  parameter int             FIFO_DEPTH      = CONFIG.input_fifo_depth,
  parameter int             FIFO_THRESHOLD  = FIFO_DEPTH - 2
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  tnoc_flit_if #(CONFIG, 1) flit_fifo_in_if[CHANNELS]();
  tnoc_flit_if #(CONFIG, 1) flit_fifo_out_if[CHANNELS]();

  tnoc_vc_demux #(CONFIG, PORT_TYPE) u_vc_demux(
    flit_in_if, flit_fifo_in_if
  );

  for (genvar i = 0;i < CHANNELS;++i) begin : g_fifo
    tnoc_flit_if_fifo #(
      .CONFIG     (CONFIG         ),
      .CHANNELS   (1              ),
      .DEPTH      (FIFO_DEPTH     ),
      .THRESHOLD  (FIFO_THRESHOLD ),
      .FIFO_MEM   (1              )
    ) u_fifo (
      .clk            (clk                  ),
      .rst_n          (rst_n                ),
      .i_clear        (),
      .o_empty        (),
      .o_almost_full  (),
      .o_full         (),
      .flit_in_if     (flit_fifo_in_if[i]   ),
      .flit_out_if    (flit_fifo_out_if[i]  )
    );
  end

  logic [CHANNELS-1:0]  vc_request;
  logic [CHANNELS-1:0]  vc_grant;
  logic [CHANNELS-1:0]  vc_free;

  for (genvar i = 0;i < CHANNELS;++i) begin
    assign  vc_request[i] = flit_fifo_out_if[i].valid;
    assign  vc_free[i]    = (flit_fifo_out_if[i].flit.tail) ? flit_fifo_out_if[i].valid & flit_fifo_out_if[i].ready : '0;
  end

  tnoc_round_robin_arbiter #(
    .REQUESTS     (CHANNELS ),
    .KEEP_RESULT  (1        )
  ) u_vc_arbiter (
    .clk  (clk),
    .rst_n  (rst_n),
    .i_request  (vc_request ),
    .o_grant    (vc_grant   ),
    .i_free     (vc_free    )
  );

  tnoc_flit_if_mux #(
    CONFIG, 1, CHANNELS, PORT_TYPE
  ) u_flit_mux (
    vc_grant, flit_fifo_out_if, flit_out_if
  );
endmodule
