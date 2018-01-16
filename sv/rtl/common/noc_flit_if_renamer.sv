module noc_flit_if_renamer (
  noc_flit_if.target    flit_in_if,
  noc_flit_if.initiator flit_out_if
);
  assign  flit_out_if.valid       = flit_in_if.valid;
  assign  flit_in_if.ready        = flit_out_if.ready;
  assign  flit_out_if.flit        = flit_in_if.flit;
  assign  flit_in_if.vc_available = flit_out_if.vc_available;
endmodule
