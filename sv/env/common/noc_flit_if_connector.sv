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
    dut_flit.head       = bfm_flit.head;
    dut_flit.tail       = bfm_flit.tail;
    dut_flit.data       = bfm_flit.data;
    return dut_flit;
  endfunction

  function automatic noc_bfm_flit convert_to_bfm_flit(input noc_flit dut_flit);
    noc_bfm_flit  bfm_flit;
    bfm_flit.flit_type  = noc_bfm_flit_type'(dut_flit.flit_type);
    bfm_flit.head       = dut_flit.head;
    bfm_flit.tail       = dut_flit.tail;
    bfm_flit.data       = dut_flit.data;
    return bfm_flit;
  endfunction

  generate for (genvar i = 0;i < IFS;++i) begin
    assign  flit_in_if[i].valid             = flit_bfm_in_if[i].valid;
    assign  flit_bfm_in_if[i].ready         = flit_in_if[i].ready;
    assign  flit_in_if[i].flit              = convert_to_dut_flit(flit_bfm_in_if[i].flit);
    assign  flit_bfm_in_if[i].vc_available  = flit_in_if[i].vc_available;

    assign  flit_bfm_out_if[i].valid    = flit_out_if[i].valid;
    assign  flit_out_if[i].ready        = flit_bfm_out_if[i].ready;
    assign  flit_bfm_out_if[i].flit     = convert_to_bfm_flit(flit_out_if[i].flit);
    assign  flit_out_if[i].vc_available = flit_bfm_out_if[i].vc_available;
  end endgenerate
endmodule
