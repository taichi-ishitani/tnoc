module noc_flit_if_connector
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG      = NOC_DEFAULT_CONFIG,
  parameter int         IFS         = 1
)(
  noc_flit_if.initiator     flit_in_if[IFS],
  noc_flit_if.target        flit_out_if[IFS],
  noc_bfm_flit_if.target    flit_bfm_in_if[IFS],
  noc_bfm_flit_if.initiator flit_bfm_out_if[IFS]
);
  import  noc_bfm_types_pkg::*;

  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  function automatic noc_flit convert_to_dut_flit(input noc_bfm_flit bfm_flit);
    noc_flit  dut_flit;
    dut_flit.flit_type  = noc_flit_type'(bfm_flit.flit_type);
    dut_flit.tail       = bfm_flit.tail;
    dut_flit.data       = bfm_flit.data;
    return dut_flit;
  endfunction

  function automatic noc_bfm_flit convert_to_bfm_flit(input noc_flit dut_flit);
    noc_bfm_flit  bfm_flit;
    bfm_flit.flit_type  = noc_bfm_flit_type'(dut_flit.flit_type);
    bfm_flit.tail       = dut_flit.tail;
    bfm_flit.data       = dut_flit.data;
    return bfm_flit;
  endfunction

  genvar  g_i;

  generate for (g_i = 0;g_i < IFS;++g_i) begin
    assign  flit_in_if[g_i].valid     = flit_bfm_in_if[g_i].valid;
    assign  flit_bfm_in_if[g_i].ready = flit_in_if[g_i].ready;
    assign  flit_in_if[g_i].flit      = convert_to_dut_flit(flit_bfm_in_if[g_i].flit);

    assign  flit_bfm_out_if[g_i].valid  = flit_out_if[g_i].valid;
    assign  flit_out_if[g_i].ready      = flit_bfm_out_if[g_i].ready;
    assign  flit_bfm_out_if[g_i].flit   = convert_to_bfm_flit(flit_out_if[g_i].flit);
  end endgenerate
endmodule
