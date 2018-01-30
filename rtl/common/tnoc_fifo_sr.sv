module tnoc_fifo_sr #(
  parameter int WIDTH     = 8,
  parameter int DEPTH     = 8,
  parameter int THRESHOLD = DEPTH
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic             i_clear,
  output  logic             o_empty,
  output  logic             o_full,
  output  logic             o_almost_full,
  input   logic             i_push,
  input   logic [WIDTH-1:0] i_data,
  input   logic             i_pop,
  output  logic [WIDTH-1:0] o_data
);
  localparam  int POINTER_WIDTH = $clog2(DEPTH + 1);

  logic                     push;
  logic                     pop;
  logic                     empty;
  logic                     almost_full;
  logic                     full;
  logic [POINTER_WIDTH-1:0] pointer;
  logic [POINTER_WIDTH-1:0] pointer_next;

//--------------------------------------------------------------
//  FIFO Control
//--------------------------------------------------------------
  assign  o_empty       = empty;
  assign  o_almost_full = almost_full;
  assign  o_full        = full;

  assign  push          = (i_push && (!full )) ? '1 : '0;
  assign  pop           = (i_pop  && (!empty)) ? '1 : '0;
  assign  pointer_next  = ({push, pop} == 2'b10) ? pointer + 1
                        : ({push, pop} == 2'b01) ? pointer - 1 : pointer;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      pointer <= '0;
      empty   <= '1;
      full    <= '0;
    end
    else if (i_clear) begin
      pointer <= '0;
      empty   <= '1;
      full    <= '0;
    end
    else if (push || pop) begin
      pointer <= pointer_next;
      empty   <= (pop  && (pointer_next == 0    )) ? '1 : '0;
      full    <= (push && (pointer_next == DEPTH)) ? '1 : '0;
    end
  end

  generate if (THRESHOLD < DEPTH) begin
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        almost_full <= '0;
      end
      else if (i_clear) begin
        almost_full <= '0;
      end
      else if (push || pop) begin
        almost_full <= (pointer_next >= THRESHOLD) ? '1 : '0;
      end
    end
  end
  else begin
    assign  almost_full = full;
  end endgenerate

//--------------------------------------------------------------
//  Shift Register
//--------------------------------------------------------------
  logic [WIDTH-1:0]         fifo[DEPTH];
  logic [POINTER_WIDTH-1:0] push_point;

  assign  push_point  = (pop) ? pointer - 1 : pointer;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      fifo  <= '{default: '0};
    end
    else begin
      if (pop) begin
        for (int i = 0;i < DEPTH;++i) begin
          fifo[i] <= (i < (DEPTH - 1)) ? fifo[i+1] : '0;
        end
      end
      if (push) begin
        fifo[push_point]  <= i_data;
      end
    end
  end

  assign  o_data  = fifo[0];
endmodule
