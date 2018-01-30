module tnoc_router_dummy (
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  assign  flit_in_if.ready        = '1;
  assign  flit_in_if.vc_available = '1;
  assign  flit_out_if.valid       = '0;
  assign  flit_out_if.flit        = '0;
endmodule
