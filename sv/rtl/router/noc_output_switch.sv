module noc_output_switch
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)(
  input logic                   clk,
  input logic                   rst_n,
  noc_flit_channel_if.target    flit_in_if[5],
  noc_flit_channel_if.initiator flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"
  `include  "noc_flit_utils.svh"

  genvar  g_i;

  //  Input Arbitration
  logic [4:0] request;
  logic [4:0] grant;
  logic [4:0] free;

  generate for (g_i = 0;g_i < 5;++g_i) begin
    assign  request[g_i]  = (
      flit_in_if[g_i].valid && is_header_flit(flit_in_if[g_i].flit)
    )? '1 : '0;
    assign  free[g_i] = (
      flit_in_if[g_i].valid && flit_in_if[g_i].ready && is_tail_flit(flit_in_if[g_i].flit)
    ) ? '1 : '0;
  end endgenerate

  noc_round_robin_arbiter #(5, 1) u_input_arbiter (
    .clk        (clk      ),
    .rst_n      (rst_n    ),
    .i_request  (request  ),
    .o_grant    (grant    ),
    .i_free     (free     )
  );

  //  MUX
  noc_flit_channel_mux #(
    .CONFIG     (CONFIG ),
    .CHANNELS   (5      ),
    .FIFO_DEPTH (2      )
  ) u_input_mux (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .i_select     (grant        ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
