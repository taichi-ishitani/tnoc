module tnoc_output_switch
  import  tnoc_config_pkg::*;
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic           clk,
  input   logic           rst_n,
  tnoc_flit_if.target     flit_in_if[5],
  tnoc_flit_if.initiator  flit_out_if,
  input   logic [4:0]     i_output_grant,
  output  logic           o_output_free
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_flit_utils.svh"

  logic [4:0]             port_free;
  tnoc_flit_if #(CONFIG)  flit_fifo_if();

  assign  o_output_free = |port_free;
  generate for (genvar i = 0;i < 5;++i) begin
    assign  port_free[i]  = |(flit_in_if[i].valid & flit_in_if[i].ready);
  end endgenerate

  tnoc_flit_if_mux #(
    .CONFIG   (CONFIG ),
    .ENTRIES  (5      )
  ) u_output_mux (
    .i_select     (i_output_grant ),
    .flit_in_if   (flit_in_if     ),
    .flit_out_if  (flit_fifo_if   )
  );

  tnoc_flit_if_fifo #(
    .CONFIG (CONFIG ),
    .DEPTH  (2      )
  ) u_output_fifo (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .i_clear        ('0           ),
    .o_empty        (),
    .o_almost_full  (),
    .o_full         (),
    .flit_in_if     (flit_fifo_if ),
    .flit_out_if    (flit_out_if  )
  );
endmodule
