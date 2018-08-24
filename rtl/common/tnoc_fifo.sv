module tnoc_fifo #(
  parameter int WIDTH       = 8,
  parameter int DEPTH       = 8,
  parameter int THRESHOLD   = DEPTH,
  parameter bit DATA_FF_OUT = 0
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
  localparam  int COUNTER_WIDTH = $clog2(DEPTH + 1);
  localparam  int RAM_WORDS     = (DATA_FF_OUT) ? DEPTH - 1 : DEPTH;
  localparam  int ADDRESS_WIDTH = (RAM_WORDS >= 2) ? $clog2(RAM_WORDS) : 1;

//--------------------------------------------------------------
//  FIFO Status
//--------------------------------------------------------------
  typedef struct packed {
    logic                     empty;
    logic                     almost_full;
    logic                     full;
    logic [COUNTER_WIDTH-1:0] word_count;
  } s_fifo_status;

  localparam  s_fifo_status INITIAL_FIFO_STATUS = '{
    empty: 1'b1, almost_full: 1'b0, full: 1'b0, word_count: 0
  };

  logic         push;
  logic         pop;
  s_fifo_status fifo_status;

  assign  o_empty       = fifo_status.empty;
  assign  o_almost_full = fifo_status.almost_full;
  assign  o_full        = fifo_status.full;

  assign  push  = (!fifo_status.full ) ? i_push : '0;
  assign  pop   = (!fifo_status.empty) ? i_pop  : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      fifo_status <= INITIAL_FIFO_STATUS;
    end
    else if (i_clear) begin
      fifo_status <= INITIAL_FIFO_STATUS;
    end
    else if (push || pop) begin
      fifo_status <= get_next_status(push, pop, fifo_status);
    end
  end

  function automatic s_fifo_status get_next_status(
    input logic         push,
    input logic         pop,
    input s_fifo_status current_status
  );
    logic [WIDTH-1:0] next_count;
    s_fifo_status     next_status;

    case ({push, pop})
      2'b10:    next_count  = current_status.word_count + 1;
      2'b01:    next_count  = current_status.word_count - 1;
      default:  next_count  = current_status.word_count;
    endcase

    next_status.empty       = (next_count == 0        ) ? '1 : '0;
    next_status.almost_full = (next_count >= THRESHOLD) ? '1 : '0;
    next_status.full        = (next_count == DEPTH    ) ? '1 : '0;
    next_status.word_count  = next_count;

    return next_status;
  endfunction

//--------------------------------------------------------------
//  Write/Read Address
//--------------------------------------------------------------
  localparam  bit [ADDRESS_WIDTH-1:0] LAST_ADDRESS  = RAM_WORDS - 1;

  logic                     write_to_ff;
  logic                     write_to_ram;
  logic [ADDRESS_WIDTH-1:0] write_address;
  logic                     read_from_ram;
  logic [ADDRESS_WIDTH-1:0] read_address;

  if (DATA_FF_OUT) begin
    assign  write_to_ff   = (((fifo_status.word_count == 1) && ( pop)) || (fifo_status.empty          )) ? '1 : '0;
    assign  write_to_ram  = (((fifo_status.word_count == 1) && (!pop)) || (fifo_status.word_count >= 2)) ? '1 : '0;
    assign  read_from_ram = (fifo_status.word_count >= 2) ? '1 : '0;
  end
  else begin
    assign  write_to_ff   = '0;
    assign  write_to_ram  = '1;
    assign  read_from_ram = '1;
  end

  if (RAM_WORDS >= 2) begin
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        write_address <= 0;
        read_address  <= 0;
      end
      else if (i_clear) begin
        write_address <= 0;
        read_address  <= 0;
      end
      else begin
        if (push && write_to_ram) begin
          write_address <= get_next_address(write_address);
        end
        if (pop && read_from_ram) begin
          read_address  <= get_next_address(read_address);
        end
      end
    end
  end
  else begin
    assign  write_address = 0;
    assign  read_address  = 0;
  end

  function automatic logic [ADDRESS_WIDTH-1:0] get_next_address(
    input logic [ADDRESS_WIDTH-1:0] current_address
  );
    if (current_address == LAST_ADDRESS) begin
      return 0;
    end
    else begin
      return current_address + 1;
    end
  endfunction

//--------------------------------------------------------------
//  RAM
//--------------------------------------------------------------
  logic [WIDTH-1:0] ram_read_data;

  if (RAM_WORDS >= 1) begin : g_ram
    logic [WIDTH-1:0] ram[RAM_WORDS];

    assign  ram_read_data = ram[read_address];
    always_ff @(posedge clk) begin
      if (push && write_to_ram) begin
        ram[write_address]  <= i_data;
      end
    end
  end
  else begin
    assign  ram_read_data = '0;
  end

//--------------------------------------------------------------
//  Output Data
//--------------------------------------------------------------
  logic [WIDTH-1:0] data_out;

  assign  o_data  = data_out;
  if (DATA_FF_OUT) begin
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        data_out  <= '0;
      end
      else if (push && write_to_ff) begin
        data_out  <= i_data;
      end
      else if (pop) begin
        data_out  <= ram_read_data;
      end
    end
  end
  else begin
    assign  data_out  = ram_read_data;
  end
endmodule
