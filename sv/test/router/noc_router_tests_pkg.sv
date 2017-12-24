`ifndef NOC_ROUTER_TESTS_PKG_SV
`define NOC_ROUTER_TESTS_PKG_SV
package noc_router_tests_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_common_env_pkg::*;
  import  noc_router_env_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "noc_router_test_base.svh"
  `include  "noc_router_sample_test.svh"
  `include  "noc_router_different_route_test.svh"
  `include  "noc_router_virtual_channel_test.svh"
endpackage
`endif

