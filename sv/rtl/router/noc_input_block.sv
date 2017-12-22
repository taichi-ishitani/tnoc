module noc_input_block
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         DEPTH     = 8,
  parameter int         X         = 0,
  parameter int         Y         = 0
)(
  input logic               clk,
  input logic               rst_n,
  noc_flit_if.target        flit_in_if,
  noc_flit_bus_if.initiator flit_out_if_x_plus,
  noc_flit_bus_if.initiator flit_out_if_x_minus,
  noc_flit_bus_if.initiator flit_out_if_y_plus,
  noc_flit_bus_if.initiator flit_out_if_y_minus,
  noc_flit_bus_if.initiator flit_out_if_local
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  noc_flit_bus_if #(CONFIG) flit_out_if[5]();

  genvar  g_i;
  genvar  g_j;

  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_channel
    noc_flit_channel_if #(CONFIG) flit_in_channel_if();
    noc_flit_channel_if #(CONFIG) flit_fifo_channel_if();
    noc_flit_channel_if #(CONFIG) flit_out_channel_if[5]();

    assign  flit_in_channel_if.valid  = flit_in_if.valid[g_i];
    assign  flit_in_if.ready[g_i]     = flit_in_channel_if.ready;
    assign  flit_in_channel_if.flit   = flit_in_if.flit;

    noc_flit_channel_fifo #(
      .CONFIG (CONFIG ),
      .DEPTH  (DEPTH  )
    ) u_input_fifo (
      .clk          (clk                  ),
      .rst_n        (rst_n                ),
      .i_clear      ('0                   ),
      .o_empty      (),
      .o_full       (),
      .flit_in_if   (flit_in_channel_if   ),
      .flit_out_if  (flit_fifo_channel_if )
    );

    noc_route_selector #(
      .CONFIG (CONFIG ),
      .X      (X      ),
      .Y      (Y      )
    ) u_route_selector (
      .clk          (clk                  ),
      .rst_n        (rst_n                ),
      .flit_in_if   (flit_fifo_channel_if ),
      .flit_out_if  (flit_out_channel_if  )
    );

    for (g_j = 0;g_j < 5;++g_j) begin
      assign  flit_out_if[g_j].valid[g_i]     = flit_out_channel_if[g_j].valid;
      assign  flit_out_channel_if[g_j].ready  = flit_out_if[g_j].ready[g_i];
      assign  flit_out_if[g_j].flit[g_i]      = flit_out_channel_if[g_j].flit;
    end
  end endgenerate

  noc_flit_bus_renamer #(CONFIG) u_renamer_x_plus(
    flit_out_if[0], flit_out_if_x_plus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_x_minus(
    flit_out_if[1], flit_out_if_x_minus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_plus(
    flit_out_if[2], flit_out_if_y_plus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_minus(
    flit_out_if[3], flit_out_if_y_minus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_local(
    flit_out_if[4], flit_out_if_local
  );
endmodule
