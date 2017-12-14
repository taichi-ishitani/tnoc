module noc_fifo #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 8
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic             i_clear,
  input   logic             i_valid,
  output  logic             o_ready,
  input   logic [WIDTH-1:0] i_data,
  output  logic             o_valid,
  input   logic             i_ready,
  output  logic [WIDTH-1:0] o_data,
  output  logic             o_empty,
  output  logic             o_full
);
  localparam  int POINTER_WIDTH = $clog2(DEPTH + 1);

  logic                     we;
  logic                     re;
  logic                     empty;
  logic                     full;
  logic [POINTER_WIDTH-1:0] pointer;
  logic [POINTER_WIDTH-1:0] pointer_next;

//--------------------------------------------------------------
//  FIFO Control
//--------------------------------------------------------------
  assign  o_empty = empty;
  assign  o_full  = full;

  assign  we            = (i_valid && (!full )) ? '1 : '0;
  assign  re            = (i_ready && (!empty)) ? '1 : '0;
  assign  pointer_next  = ({we, re} == 2'b10) ? pointer + 1
                        : ({we, re} == 2'b01) ? pointer - 1 : pointer;
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
    else if (we || re) begin
      pointer <= pointer_next;
      empty   <= (re && (pointer_next == 0    )) ? 1 : 0;
      full    <= (we && (pointer_next == DEPTH)) ? 1 : 0;
    end
  end

//--------------------------------------------------------------
//  FIFO Control
//--------------------------------------------------------------
  logic [WIDTH-1:0]         fifo[DEPTH];
  logic [POINTER_WIDTH-1:0] write_point;

  assign  write_point = (we && re) ? pointer - 1 : pointer;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      fifo  <= '{default: '0};
    end
    else if (i_clear) begin
      fifo  <= '{default: '0};
    end
    else if (we || re) begin
      for (int i = 0;i < DEPTH;++i) begin
        if (i < write_point) begin
          fifo[i] <= fifo[i+1];
        end
        else if (i == write_point) begin
          fifo[i] <= i_data;
        end
        else begin
          fifo[i] <= '0;
        end
      end
    end
  end

//--------------------------------------------------------------
//  In/Out Interface
//--------------------------------------------------------------
  assign  o_ready = (!full ) ? '1 : '0;
  assign  o_valid = (!empty) ? '1 : '0;
  assign  o_data  = fifo[0];
endmodule
