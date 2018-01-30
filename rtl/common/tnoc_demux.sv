module tnoc_demux #(
  parameter int             WIDTH   = 8,
  parameter int             ENTRIES = 8,
  parameter bit [WIDTH-1:0] DEFAULT = '0
)(
  input   logic [ENTRIES-1:0] i_select,
  input   logic [WIDTH-1:0]   i_value,
  output  logic [WIDTH-1:0]   o_value[ENTRIES]
);
  generate for (genvar i = 0;i < ENTRIES;++i) begin
    assign  o_value[i]  = (i_select[i]) ? i_value : DEFAULT;
  end endgenerate
endmodule
