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
  noc_flit_bus_if #(CONFIG) flit_fifo_out_if();

  noc_input_fifo #(
    .CONFIG (CONFIG ),
    .DEPTH  (DEPTH  )
  ) u_input_fifo (
    .clk          (clk              ),
    .rst_n        (rst_n            ),
    .i_clear      ('0),
    .o_empty      (),
    .o_full       (),
    .flit_in_if   (flit_in_if       ),
    .flit_out_if  (flit_fifo_out_if )
  );

  noc_route_selector #(
    .CONFIG (CONFIG ),
    .X      (X      ),
    .Y      (Y      )
  ) u_route_selector (
    .clk                  (clk                  ),
    .rst_n                (rst_n                ),
    .flit_in_if           (flit_fifo_out_if     ),
    .flit_out_if_x_plus   (flit_out_if_x_plus   ),
    .flit_out_if_x_minus  (flit_out_if_x_minus  ),
    .flit_out_if_y_plus   (flit_out_if_y_plus   ),
    .flit_out_if_y_minus  (flit_out_if_y_minus  ),
    .flit_out_if_local    (flit_out_if_local    )
  );
endmodule
