module noc_value_keeper #(
  parameter int             WIDTH         = 1,
  parameter bit [WIDTH-1:0] INITIAL_VALUE = '0
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic             i_clear,
  input   logic             i_valid,
  input   logic [WIDTH-1:0] i_value,
  output  logic [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value_latched;

  assign  o_value = (i_valid) ? i_value : value_latched;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      value_latched <= INITIAL_VALUE;
    end
    else if (i_clear) begin
      value_latched <= INITIAL_VALUE;
    end
    else if (i_valid) begin
      value_latched <= i_value;
    end
  end
endmodule
