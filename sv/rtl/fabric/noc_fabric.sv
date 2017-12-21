module noc_fabric
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG      = NOC_DEFAULT_CONFIG,
  parameter   int         FIFO_DEPTH  = 8,
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

  genvar  g_i;
  genvar  g_j;

  generate for (g_i = 0;g_i < SIZE_Y;++g_i) begin : g_y
    for (g_j = 0;g_j < SIZE_X;++g_j) begin : g_x
      localparam  int FLIT_IF_INDEX_X = 2 * ((SIZE_X + 1) * g_i + g_j);
      localparam  int FLIT_IF_INDEX_Y = 2 * ((SIZE_Y + 1) * g_j + g_i);
      localparam  int FLIT_IF_INDEX_L = 1 * ((SIZE_X + 0) * g_i + g_j);

      noc_router #(
        .CONFIG (CONFIG     ),
        .DEPTH  (FIFO_DEPTH ),
        .X      (g_j        ),
        .Y      (g_i        )
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

      if (g_j == 0) begin : g_dummy_left
        noc_dummy_router #(CONFIG) u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+1], flit_if_x[FLIT_IF_INDEX_X+0]
        );
      end
      else if (g_j == (SIZE_X - 1)) begin : g_dummy_right
        noc_dummy_router #(CONFIG) u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+2], flit_if_x[FLIT_IF_INDEX_X+3]
        );
      end

      if (g_i == 0) begin : g_dummy_bottom
        noc_dummy_router #(CONFIG) u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+1], flit_if_y[FLIT_IF_INDEX_Y+0]
        );
      end
      else if (g_i == (SIZE_Y - 1)) begin : g_dummy_top
        noc_dummy_router #(CONFIG) u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+2], flit_if_y[FLIT_IF_INDEX_Y+3]
        );
      end
    end
  end endgenerate
endmodule
