module noc_flit_if_fifo
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG,
  parameter int         DEPTH   = 8
)(
  input   logic       clk,
  input   logic       rst_n,
  noc_flit_if.slave   flit_in_if,
  noc_flit_if.master  flit_out_if,
  input   logic       i_clear,
  output  logic       o_empty,
  output  logic       o_full
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  noc_fifo #(
    .WIDTH  (FLIT_WIDTH ),
    .DEPTH  (DEPTH      )
  ) u_fifo (
    .clk      (clk                ),
    .rst_n    (rst_n              ),
    .i_clear  (i_clear            ),
    .i_valid  (flit_in_if.valid   ),
    .o_ready  (flit_in_if.ready   ),
    .i_data   (flit_in_if.flit    ),
    .o_valid  (flit_out_if.valid  ),
    .i_ready  (flit_out_if.ready  ),
    .o_data   (flit_out_if.flit   ),
    .o_empty  (o_empty            ),
    .o_full   (o_full             )
  );
endmodule
