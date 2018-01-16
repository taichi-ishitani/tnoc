module noc_vc_merger
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic                 clk,
  input logic                 rst_n,
  input logic [CHANNELS-1:0]  i_vc_grant,
  noc_flit_if.target          flit_in_if[CHANNELS],
  noc_flit_if.initiator       flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [FLIT_WIDTH-1:0]  flit_in[CHANNELS];
  logic [FLIT_WIDTH-1:0]  flit_out;
  noc_flit_if #(CONFIG)   flit_fifo_if();

  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  flit_fifo_if.valid[i]       = (i_vc_grant[i]) ? flit_in_if[i].valid   : '0;
    assign  flit_in_if[i].ready         = (i_vc_grant[i]) ? flit_fifo_if.ready[i] : '0;
    assign  flit_in[i]                  = flit_in_if[i].flit;
    assign  flit_in_if[i].vc_available  = '0;
  end endgenerate

  assign  flit_fifo_if.flit   = flit_out;
  noc_mux #(
    .WIDTH    (FLIT_WIDTH ),
    .ENTRIES  (CHANNELS   )
  ) u_flit_mux (
    .i_select (i_vc_grant ),
    .i_value  (flit_in    ),
    .o_value  (flit_out   )
  );

  noc_flit_if_fifo #(
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
