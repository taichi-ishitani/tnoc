module noc_flit_if_mux
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG,
  parameter int         IFS     = 2
)(
  input logic [IFS-1:0] i_select,
  noc_flit_if.slave     flit_in_if[IFS],
  noc_flit_if.master    flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [IFS-1:0] valid;
  noc_flit        flit[IFS];
  genvar          g_i;

  generate for(g_i = 0;g_i < IFS;++g_i) begin
    assign  valid[g_i]            = (i_select[g_i]) ? flit_in_if[g_i].valid : '0;
    assign  flit[g_i]             = (i_select[g_i]) ? flit_in_if[g_i].flit  : '0;
    assign  flit_in_if[g_i].ready = (i_select[g_i]) ? flit_out_if.ready     : '0;
  end endgenerate

  assign  flit_out_if.valid = |valid;
  assign  flit_out_if.flit  = merge_flit(flit);

  function automatic noc_flit merge_flit(input noc_flit flit[IFS]);
    noc_flit  flit_merged;
    for (int i = 0;i < FLIT_WIDTH;++i) begin
      logic [IFS-1:0] temp;
      for (int j = 0;j < IFS;++j) begin
        temp[j] = flit[j][i];
      end
      flit_merged[i]  = |temp;
    end
    return flit_merged;
  endfunction
endmodule
