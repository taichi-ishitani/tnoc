module noc_router
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         DEPTH     = 8,
  parameter int         X         = 0,
  parameter int         Y         = 0
)(
  input logic           clk,
  input logic           rst_n,
  noc_flit_if.target    flit_in_if_x_plus,
  noc_flit_if.initiator flit_out_if_x_plus,
  noc_flit_if.target    flit_in_if_x_minus,
  noc_flit_if.initiator flit_out_if_x_minus,
  noc_flit_if.target    flit_in_if_y_plus,
  noc_flit_if.initiator flit_out_if_y_plus,
  noc_flit_if.target    flit_in_if_y_minus,
  noc_flit_if.initiator flit_out_if_y_minus,
  noc_flit_if.target    flit_in_if_local,
  noc_flit_if.initiator flit_out_if_local
);
  noc_flit_if #(CONFIG)     flit_in_if[5]();
  noc_flit_if #(CONFIG)     flit_out_if[5]();
  noc_flit_bus_if #(CONFIG) flit_bus_if[25]();
  genvar                    g_i;

//--------------------------------------------------------------
//  Renaming
//--------------------------------------------------------------
  noc_flit_if_renamer #(CONFIG) u_flit_in_renamer_x_plus (
    flit_in_if_x_plus, flit_in_if[0]
  );
  noc_flit_if_renamer #(CONFIG) u_flit_out_renamer_x_plus (
    flit_out_if[0], flit_out_if_x_plus
  );
  noc_flit_if_renamer #(CONFIG) u_flit_in_renamer_x_minus (
    flit_in_if_x_minus, flit_in_if[1]
  );
  noc_flit_if_renamer #(CONFIG) u_flit_out_renamer_x_minus (
    flit_out_if[1], flit_out_if_x_minus
  );
  noc_flit_if_renamer #(CONFIG) u_flit_in_renamer_y_plus (
    flit_in_if_y_plus, flit_in_if[2]
  );
  noc_flit_if_renamer #(CONFIG) u_flit_out_renamer_y_plus (
    flit_out_if[2], flit_out_if_y_plus
  );
  noc_flit_if_renamer #(CONFIG) u_flit_in_renamer_y_minus (
    flit_in_if_y_minus, flit_in_if[3]
  );
  noc_flit_if_renamer #(CONFIG) u_flit_out_renamer_y_minus (
    flit_out_if[3], flit_out_if_y_minus
  );
  noc_flit_if_renamer #(CONFIG) u_flit_in_renamer_local (
    flit_in_if_local, flit_in_if[4]
  );
  noc_flit_if_renamer #(CONFIG) u_flit_out_renamer_local (
    flit_out_if[4], flit_out_if_local
  );

//--------------------------------------------------------------
//  Input Blocks
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < 5;++g_i) begin : g_input_block
    noc_input_block #(
      .CONFIG (CONFIG ),
      .DEPTH  (DEPTH  ),
      .X      (X      ),
      .Y      (Y      )
    ) u_input_block (
      .clk                  (clk                  ),
      .rst_n                (rst_n                ),
      .flit_in_if           (flit_in_if[g_i]      ),
      .flit_out_if_x_plus   (flit_bus_if[5*g_i+0] ),
      .flit_out_if_x_minus  (flit_bus_if[5*g_i+1] ),
      .flit_out_if_y_plus   (flit_bus_if[5*g_i+2] ),
      .flit_out_if_y_minus  (flit_bus_if[5*g_i+3] ),
      .flit_out_if_local    (flit_bus_if[5*g_i+4] )
    );
  end endgenerate

//--------------------------------------------------------------
//  Output Switch
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < 5;++g_i) begin : g_output_switch
    noc_output_switch #(
      .CONFIG (CONFIG )
    ) u_output_switch (
      .clk                (clk                  ),
      .rst_n              (rst_n                ),
      .flit_in_if_x_plus  (flit_bus_if[5*0+g_i] ),
      .flit_in_if_x_minus (flit_bus_if[5*1+g_i] ),
      .flit_in_if_y_plus  (flit_bus_if[5*2+g_i] ),
      .flit_in_if_y_minus (flit_bus_if[5*3+g_i] ),
      .flit_in_if_local   (flit_bus_if[5*4+g_i] ),
      .flit_out_if        (flit_out_if[g_i]     )
    );
  end endgenerate
endmodule
