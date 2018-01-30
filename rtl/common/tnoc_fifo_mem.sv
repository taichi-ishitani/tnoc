module tnoc_fifo_mem #(
  parameter int WIDTH     = 8,
  parameter int DEPTH     = 8,
  parameter int THRESHOLD = DEPTH
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
  localparam  int                     COUNTER_WIDTH = $clog2(DEPTH + 1);
  localparam  int                     ADDRESS_WIDTH = $clog2(DEPTH - 1);
  localparam  bit [ADDRESS_WIDTH-1:0] LAST_ADDRESS  = DEPTH - 2;

  logic                     push;
  logic                     pop;
  logic                     empty;
  logic                     almost_full;
  logic                     full;
  logic [COUNTER_WIDTH-1:0] word_counter;
  logic [COUNTER_WIDTH-1:0] word_counter_next;
  logic                     write_to_buffer;
  logic                     write_to_memory;
  logic [ADDRESS_WIDTH-1:0] write_address;
  logic [ADDRESS_WIDTH-1:0] read_address;
  logic [WIDTH-1:0]         memory[DEPTH-1];
  logic [WIDTH-1:0]         output_buffer;

//--------------------------------------------------------------
//  FIFO Control
//--------------------------------------------------------------
  assign  o_empty       = empty;
  assign  o_almost_full = almost_full;
  assign  o_full        = full;

  assign  push              = (!full ) ? i_push : '0;
  assign  pop               = (!empty) ? i_pop  : '0;
  assign  word_counter_next = ({push, pop} == 2'b10) ? word_counter + 1
                            : ({push, pop} == 2'b01) ? word_counter - 1 : word_counter;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      word_counter  <= 0;
      empty         <= '1;
      full          <= '0;
    end
    else if (push || pop) begin
      word_counter  <= word_counter_next;
      empty         <= (pop  && (word_counter_next == 0    )) ? '1 : '0;
      full          <= (push && (word_counter_next == DEPTH)) ? '1 : '0;
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
        almost_full <= (word_counter_next >= THRESHOLD) ? '1 : '0;
      end
    end
  end
  else begin
    assign  almost_full = full;
  end endgenerate

//--------------------------------------------------------------
//  Memory Control
//--------------------------------------------------------------
  assign  o_data  = output_buffer;

  assign  write_to_buffer = (empty  || ((word_counter == 1) && pop)) ? '1 : '0;
  assign  write_to_memory = ((word_counter >= 2) || ((word_counter == 1) && (!pop))) ? '1 : '0;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      write_address <= 0;
    end
    else if (i_clear) begin
      write_address <= 0;
    end
    else if (push && write_to_memory) begin
      write_address <= calc_next_address(write_address);
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      read_address  <= 0;
    end
    else if (i_clear) begin
      read_address  <= 0;
    end
    else if (pop && (word_counter >= 2)) begin
      read_address  <= calc_next_address(read_address);
    end
  end

  always_ff @(posedge clk) begin
    if (push && write_to_memory) begin
      memory[write_address] <= i_data;
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      output_buffer <= '0;
    end
    else if (push && write_to_buffer) begin
      output_buffer <= i_data;
    end
    else if (pop) begin
      output_buffer <= memory[read_address];
    end
  end

  function automatic logic [ADDRESS_WIDTH-1:0] calc_next_address(
    input logic [ADDRESS_WIDTH-1:0] current_address
  );
    if (current_address == LAST_ADDRESS) begin
      return 0;
    end
    else begin
      return current_address + 1;
    end
  endfunction
endmodule
