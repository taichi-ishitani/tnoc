module noc_dummy_router
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)(
  noc_flit_if.target    noc_flit_in_if,
  noc_flit_if.initiator noc_flit_out_if
);
  assign  noc_flit_in_if.ready  = '1;
  assign  noc_flit_out_if.valid = '0;
  assign  noc_flit_out_if.flit  = '0;
endmodule
