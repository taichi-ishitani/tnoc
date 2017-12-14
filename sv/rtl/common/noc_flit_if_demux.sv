module noc_flit_if_demux # (
  parameter int IFS = 2
)(
  input [IFS-1:0]     i_select,
  noc_flit_if.slave   flit_in_if,
  noc_flit_if.master  flit_out_if[IFS]
);
  logic [IFS-1:0] ready;
  genvar          g_i;

  assign  flit_in_if.ready  = |ready;

  generate for (g_i = 0;g_i < IFS;++g_i) begin
    assign  flit_out_if[g_i].valid  = (i_select[g_i]) ? flit_in_if.valid       : '0;
    assign  flit_out_if[g_i].flit   = (i_select[g_i]) ? flit_in_if.flit        : '0;
    assign  ready[g_i]              = (i_select[g_i]) ? flit_out_if[g_i].ready : '0;
  end endgenerate
endmodule
