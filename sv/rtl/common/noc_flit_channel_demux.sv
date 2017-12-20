module noc_flit_channel_demux
    import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG      = NOC_DEFAULT_CONFIG,
  parameter int         CHANNELS    = 5,
  parameter int         FIFO_DEPTH  = 0
)(
  input logic                   clk,
  input logic                   rst_n,
  input logic [CHANNELS-1:0]    i_select,
  noc_flit_channel_if.target    flit_in_if,
  noc_flit_channel_if.initiator flit_out_if[CHANNELS]
);
  logic [CHANNELS-1:0]  flit_in_ready;
  genvar                g_i;

  assign  flit_in_if.ready  = |flit_in_ready;

  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_channel
    noc_flit_channel_if #(CONFIG) flit_demux_if();

    assign  flit_demux_if.valid = (i_select[g_i]) ? flit_in_if.valid    : '0;
    assign  flit_demux_if.flit  = (i_select[g_i]) ? flit_in_if.flit     : '0;
    assign  flit_in_ready[g_i]  = (i_select[g_i]) ? flit_demux_if.ready : '0;

    if (FIFO_DEPTH > 0) begin : g_fifo
      noc_flit_channel_fifo #(
        .CONFIG (CONFIG     ),
        .DEPTH  (FIFO_DEPTH )
      ) u_fifo (
        .clk          (clk              ),
        .rst_n        (rst_n            ),
        .i_clear      ('0               ),
        .o_empty      (),
        .o_full       (),
        .flit_in_if   (flit_demux_if    ),
        .flit_out_if  (flit_out_if[g_i] )
      );
    end
    else begin : g_no_fifo
      assign  flit_out_if[g_i].valid  = flit_demux_if.valid;
      assign  flit_demux_if.ready     = flit_out_if[g_i].ready;
      assign  flit_out_if[g_i].flit   = flit_demux_if.flit;
    end
  end endgenerate
endmodule
