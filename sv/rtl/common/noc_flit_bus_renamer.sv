module noc_flit_bus_renamer
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG
)(
  noc_flit_bus_if.target    flit_in_if,
  noc_flit_bus_if.initiator flit_out_if
);
  assign  flit_out_if.valid = flit_in_if.valid;
  assign  flit_in_if.ready  = flit_out_if.ready;
  assign  flit_out_if.flit  = flit_in_if.flit;
endmodule
