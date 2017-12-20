module noc_input_fifo
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter   int         DEPTH     = 8,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic                 clk,
  input   logic                 rst_n,
  input   logic                 i_clear,
  output  logic [CHANNELS-1:0]  o_empty,
  output  logic [CHANNELS-1:0]  o_full,
  noc_flit_if.target            flit_in_if,
  noc_flit_bus_if.initiator     flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  generate for (genvar g_i = 0;g_i < CHANNELS;++g_i) begin : g_fifo
    noc_fifo #(
      .WIDTH  (FLIT_WIDTH ),
      .DEPTH  (DEPTH      )
    ) u_fifo(
      .clk      (clk                    ),
      .rst_n    (rst_n                  ),
      .i_clear  (i_clear                ),
      .o_empty  (o_empty[g_i]           ),
      .o_full   (o_full[g_i]            ),
      .i_valid  (flit_in_if.valid[g_i]  ),
      .o_ready  (flit_in_if.ready[g_i]  ),
      .i_data   (flit_in_if.flit        ),
      .o_valid  (flit_out_if.valid[g_i] ),
      .i_ready  (flit_out_if.ready[g_i] ),
      .o_data   (flit_out_if.flit[g_i]  )
    );
  end endgenerate
endmodule
