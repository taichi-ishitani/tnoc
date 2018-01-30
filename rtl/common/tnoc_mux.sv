module tnoc_mux #(
  parameter int WIDTH   = 2,
  parameter int ENTRIES = 2
)(
  input   logic [ENTRIES-1:0] i_select,
  input   logic [WIDTH-1:0]   i_value[ENTRIES],
  output  logic [WIDTH-1:0]   o_value
);
  assign  o_value = mux(i_select, i_value);

  function automatic logic [WIDTH-1:0] mux(
    input logic [ENTRIES-1:0] select,
    input logic [WIDTH-1:0]   value[ENTRIES]
  );
    logic [WIDTH-1:0] out;

    for (int i = 0;i < WIDTH;++i) begin
      logic [ENTRIES-1:0] temp;
      for (int j = 0;j < ENTRIES;++j) begin
        temp[j] = select[j] & value[j][i];
      end
      out[i]  = |temp;
    end

    return out;
  endfunction
endmodule
