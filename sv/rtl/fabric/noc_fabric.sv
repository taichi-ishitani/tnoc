module noc_fabric
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG      = NOC_DEFAULT_CONFIG,
  localparam  int         SIZE_X      = CONFIG.size_x,
  localparam  int         SIZE_Y      = CONFIG.size_y,
  localparam  int         TOTAL_SIZE  = SIZE_X * SIZE_Y
)(
  input logic           clk,
  input logic           rst_n,
  noc_flit_if.target    flit_in_if[TOTAL_SIZE],
  noc_flit_if.initiator flit_out_if[TOTAL_SIZE]
);
  localparam  int FLIT_IF_SIZE_X  = 2 * (SIZE_X + 1) * (SIZE_Y + 0);
  localparam  int FLIT_IF_SIZE_Y  = 2 * (SIZE_X + 0) * (SIZE_Y + 1);

  noc_flit_if #(CONFIG) flit_if_x[FLIT_IF_SIZE_X]();
  noc_flit_if #(CONFIG) flit_if_y[FLIT_IF_SIZE_Y]();

  generate for (genvar y = 0;y < SIZE_Y;++y) begin : g_y
    for (genvar x = 0;x < SIZE_X;++x) begin : g_x
      localparam  int       FLIT_IF_INDEX_X = 2 * ((SIZE_X + 1) * y + x);
      localparam  int       FLIT_IF_INDEX_Y = 2 * ((SIZE_Y + 1) * x + y);
      localparam  int       FLIT_IF_INDEX_L = 1 * ((SIZE_Y + 0) * y + x);
      localparam  bit [4:0] AVAILABLE_PORTS = {
        1'b1,                               //  Local
        ((y > 0           ) ? 1'b1 : 1'b0), //  Y Minus
        ((y < (SIZE_Y - 1)) ? 1'b1 : 1'b0), //  Y Plus
        ((x > 0           ) ? 1'b1 : 1'b0), //  X Minus
        ((x < (SIZE_X - 1)) ? 1'b1 : 1'b0)  //  X Plus
      };

      noc_router #(
        .CONFIG           (CONFIG           ),
        .X                (x                ),
        .Y                (y                ),
        .AVAILABLE_PORTS  (AVAILABLE_PORTS  )
      ) u_router (
        .clk                  (clk                          ),
        .rst_n                (rst_n                        ),
        .flit_in_if_x_plus    (flit_if_x[FLIT_IF_INDEX_X+3] ),
        .flit_out_if_x_plus   (flit_if_x[FLIT_IF_INDEX_X+2] ),
        .flit_in_if_x_minus   (flit_if_x[FLIT_IF_INDEX_X+0] ),
        .flit_out_if_x_minus  (flit_if_x[FLIT_IF_INDEX_X+1] ),
        .flit_in_if_y_plus    (flit_if_y[FLIT_IF_INDEX_Y+3] ),
        .flit_out_if_y_plus   (flit_if_y[FLIT_IF_INDEX_Y+2] ),
        .flit_in_if_y_minus   (flit_if_y[FLIT_IF_INDEX_Y+0] ),
        .flit_out_if_y_minus  (flit_if_y[FLIT_IF_INDEX_Y+1] ),
        .flit_in_if_local     (flit_in_if[FLIT_IF_INDEX_L]  ),
        .flit_out_if_local    (flit_out_if[FLIT_IF_INDEX_L] )
      );

      if (x == 0) begin : g_dummy_x_minus
        noc_router_dummy u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+1], flit_if_x[FLIT_IF_INDEX_X+0]
        );
      end

      if (x == (SIZE_X - 1)) begin : g_dummy_x_plus
        noc_router_dummy u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+2], flit_if_x[FLIT_IF_INDEX_X+3]
        );
      end

      if (y == 0) begin : g_dummy_y_minus
        noc_router_dummy u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+1], flit_if_y[FLIT_IF_INDEX_Y+0]
        );
      end

      if (y == (SIZE_Y - 1)) begin : g_dummy_y_plus
        noc_router_dummy u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+2], flit_if_y[FLIT_IF_INDEX_Y+3]
        );
      end
    end
  end endgenerate
endmodule
