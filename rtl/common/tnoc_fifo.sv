module tnoc_fifo #(
  parameter int WIDTH     = 8,
  parameter int DEPTH     = 8,
  parameter int THRESHOLD = DEPTH,
  parameter bit FIFO_MEM  = 0
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic             i_clear,
  output  logic             o_empty,
  output  logic             o_almost_full,
  output  logic             o_full,
  input   logic             i_push,
  input   logic [WIDTH-1:0] i_data,
  input   logic             i_pop,
  output  logic [WIDTH-1:0] o_data
);
  if (FIFO_MEM) begin : g_fifo_mem
    tnoc_fifo_mem #(
      .WIDTH      (WIDTH      ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  )
    ) u_fifo (
      .clk            (clk           ),
      .rst_n          (rst_n         ),
      .i_clear        (i_clear       ),
      .o_empty        (o_empty       ),
      .o_almost_full  (o_almost_full ),
      .o_full         (o_full        ),
      .i_push         (i_push        ),
      .i_data         (i_data        ),
      .i_pop          (i_pop         ),
      .o_data         (o_data        )
    );
  end
  else begin : g_fifo_sr
    tnoc_fifo_sr #(
      .WIDTH      (WIDTH      ),
      .DEPTH      (DEPTH      ),
      .THRESHOLD  (THRESHOLD  )
    ) u_fifo (
      .clk            (clk           ),
      .rst_n          (rst_n         ),
      .i_clear        (i_clear       ),
      .o_empty        (o_empty       ),
      .o_almost_full  (o_almost_full ),
      .o_full         (o_full        ),
      .i_push         (i_push        ),
      .i_data         (i_data        ),
      .i_pop          (i_pop         ),
      .o_data         (o_data        )
    );
  end
endmodule
