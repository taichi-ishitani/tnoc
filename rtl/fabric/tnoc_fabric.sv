module tnoc_fabric
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG      = TNOC_DEFAULT_CONFIG,
  localparam  int         SIZE_X      = CONFIG.size_x,
  localparam  int         SIZE_Y      = CONFIG.size_y,
  localparam  int         TOTAL_SIZE  = SIZE_X * SIZE_Y
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if[TOTAL_SIZE],
  tnoc_flit_if.initiator  flit_out_if[TOTAL_SIZE]
);
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS        = CONFIG.virtual_channels;
  localparam  int ID_X_WIDTH      = CONFIG.id_x_width;
  localparam  int ID_Y_WIDTH      = CONFIG.id_y_width;
  localparam  int FLIT_IF_SIZE_X  = 2 * (SIZE_X + 1) * (SIZE_Y + 0);
  localparam  int FLIT_IF_SIZE_Y  = 2 * (SIZE_X + 0) * (SIZE_Y + 1);

  `tnoc_internal_flit_if(CHANNELS)  flit_if_x[FLIT_IF_SIZE_X]();
  `tnoc_internal_flit_if(CHANNELS)  flit_if_y[FLIT_IF_SIZE_Y]();

  for (genvar y = 0;y < SIZE_Y;++y) begin : g_y
    for (genvar x = 0;x < SIZE_X;++x) begin : g_x
      localparam  int                   FLIT_IF_INDEX_X = 2 * ((SIZE_X + 1) * y + x);
      localparam  int                   FLIT_IF_INDEX_Y = 2 * ((SIZE_Y + 1) * x + y);
      localparam  int                   FLIT_IF_INDEX_L = 1 * ((SIZE_Y + 0) * y + x);
      localparam  bit [ID_X_WIDTH-1:0]  ID_X            = x;
      localparam  bit [ID_Y_WIDTH-1:0]  ID_Y            = y;
      localparam  bit [4:0]             AVAILABLE_PORTS = {
        1'b1,                               //  Local
        ((y > 0           ) ? 1'b1 : 1'b0), //  Y Minus
        ((y < (SIZE_Y - 1)) ? 1'b1 : 1'b0), //  Y Plus
        ((x > 0           ) ? 1'b1 : 1'b0), //  X Minus
        ((x < (SIZE_X - 1)) ? 1'b1 : 1'b0)  //  X Plus
      };

      tnoc_router #(
        .CONFIG           (CONFIG           ),
        .AVAILABLE_PORTS  (AVAILABLE_PORTS  )
      ) u_router (
        .clk                  (clk                          ),
        .rst_n                (rst_n                        ),
        .i_id_x               (ID_X                         ),
        .i_id_y               (ID_Y                         ),
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

      if (!AVAILABLE_PORTS[0]) begin : g_dummy_x_plus
        tnoc_router_dummy #(CONFIG, TNOC_INTERNAL_PORT) u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+2], flit_if_x[FLIT_IF_INDEX_X+3]
        );
      end
      if (!AVAILABLE_PORTS[1]) begin : g_dummy_x_minus
        tnoc_router_dummy #(CONFIG, TNOC_INTERNAL_PORT) u_dummy (
          flit_if_x[FLIT_IF_INDEX_X+1], flit_if_x[FLIT_IF_INDEX_X+0]
        );
      end
      if (!AVAILABLE_PORTS[2]) begin : g_dummy_y_plus
        tnoc_router_dummy #(CONFIG, TNOC_INTERNAL_PORT) u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+2], flit_if_y[FLIT_IF_INDEX_Y+3]
        );
      end
      if (!AVAILABLE_PORTS[3]) begin : g_dummy_y_minus
        tnoc_router_dummy #(CONFIG, TNOC_INTERNAL_PORT) u_dummy (
          flit_if_y[FLIT_IF_INDEX_Y+1], flit_if_y[FLIT_IF_INDEX_Y+0]
        );
      end
    end
  end
endmodule
