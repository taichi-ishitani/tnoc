module noc_output_block
  import  noc_config_pkg::*;
#(
    parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)(
  input logic             clk,
  input logic             rst_n,
  noc_flit_bus_if.target  flit_in_if_x_plus,
  noc_flit_bus_if.target  flit_in_if_x_minus,
  noc_flit_bus_if.target  flit_in_if_y_plus,
  noc_flit_bus_if.target  flit_in_if_y_minus,
  noc_flit_bus_if.target  flit_in_if_local,
  noc_flit_if.initiator   flit_out_if
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  noc_flit_bus_if #(CONFIG)     flit_in_if[5]();
  noc_flit_channel_if #(CONFIG) flit_channel_out_if[CHANNELS]();

  genvar  g_i;
  genvar  g_j;

  noc_flit_bus_renamer #(CONFIG) u_renamer_x_plus (
    flit_in_if_x_plus, flit_in_if[0]
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_x_minus (
    flit_in_if_x_minus, flit_in_if[1]
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_plus (
    flit_in_if_y_plus, flit_in_if[2]
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_minus (
    flit_in_if_y_minus, flit_in_if[3]
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_local (
    flit_in_if_local, flit_in_if[4]
  );

  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_channel
    noc_flit_channel_if #(CONFIG) flit_channel_in_if[5]();

    for (g_j = 0;g_j < 5;++g_j) begin
      assign  flit_channel_in_if[g_j].valid = flit_in_if[g_j].valid[g_i];
      assign  flit_in_if[g_j].ready[g_i]    = flit_channel_in_if[g_j].ready;
      assign  flit_channel_in_if[g_j].flit  = flit_in_if[g_j].flit[g_i];
    end

    noc_output_switch #(
      .CONFIG (CONFIG )
    ) u_output_switch (
      .clk          (clk                      ),
      .rst_n        (rst_n                    ),
      .flit_in_if   (flit_channel_in_if       ),
      .flit_out_if  (flit_channel_out_if[g_i] )
    );
  end endgenerate

  noc_flit_channe_merger #(
    .CONFIG (CONFIG )
  ) u_channe_merger (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .flit_in_if   (flit_channel_out_if  ),
    .flit_out_if  (flit_out_if          )
  );
endmodule
