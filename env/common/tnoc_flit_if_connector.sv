module tnoc_flit_if_connector
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG      = TNOC_DEFAULT_CONFIG,
  parameter int         IFS         = 1,
  parameter bit         ACTIVE_MODE = 1
)(
  tnoc_flit_if      flit_in_if[IFS],
  tnoc_flit_if      flit_out_if[IFS],
  tnoc_bfm_flit_if  flit_bfm_in_if[IFS],
  tnoc_bfm_flit_if  flit_bfm_out_if[IFS]
);
  import  tnoc_bfm_types_pkg::*;

  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  function automatic tnoc_flit convert_to_dut_flit(input tnoc_bfm_flit bfm_flit);
    tnoc_flit dut_flit;
    dut_flit.flit_type  = tnoc_flit_type'(bfm_flit.flit_type);
    dut_flit.head       = bfm_flit.head;
    dut_flit.tail       = bfm_flit.tail;
    dut_flit.data       = bfm_flit.data;
    return dut_flit;
  endfunction

  function automatic tnoc_bfm_flit convert_to_bfm_flit(input tnoc_flit dut_flit);
    tnoc_bfm_flit bfm_flit;
    bfm_flit.flit_type  = tnoc_bfm_flit_type'(dut_flit.flit_type);
    bfm_flit.head       = dut_flit.head;
    bfm_flit.tail       = dut_flit.tail;
    bfm_flit.data       = dut_flit.data;
    return bfm_flit;
  endfunction

  generate for (genvar i = 0;i < IFS;++i) begin
    if (ACTIVE_MODE) begin
      assign  flit_in_if[i].valid             = flit_bfm_in_if[i].valid;
      assign  flit_bfm_in_if[i].ready         = flit_in_if[i].ready;
      assign  flit_in_if[i].flit              = convert_to_dut_flit(flit_bfm_in_if[i].flit);
      assign  flit_bfm_in_if[i].vc_available  = flit_in_if[i].vc_available;

      assign  flit_bfm_out_if[i].valid    = flit_out_if[i].valid;
      assign  flit_out_if[i].ready        = flit_bfm_out_if[i].ready;
      assign  flit_bfm_out_if[i].flit     = convert_to_bfm_flit(flit_out_if[i].flit);
      assign  flit_out_if[i].vc_available = flit_bfm_out_if[i].vc_available;
    end
    else begin
      assign  flit_bfm_in_if[i].valid         = flit_in_if[i].valid;
      assign  flit_bfm_in_if[i].ready         = flit_in_if[i].ready;
      assign  flit_bfm_in_if[i].flit          = convert_to_bfm_flit(flit_in_if[i].flit);
      assign  flit_bfm_in_if[i].vc_available  = flit_in_if[i].vc_available;

      assign  flit_bfm_out_if[i].valid        = flit_out_if[i].valid;
      assign  flit_bfm_out_if[i].ready        = flit_out_if[i].ready;
      assign  flit_bfm_out_if[i].flit         = convert_to_bfm_flit(flit_out_if[i].flit);
      assign  flit_bfm_out_if[i].vc_available = flit_out_if[i].vc_available;
    end
  end endgenerate
endmodule
