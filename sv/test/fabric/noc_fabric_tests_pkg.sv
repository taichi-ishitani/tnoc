`ifndef NOC_FABRIC_TESTS_PKG_SV
`define NOC_FABRIC_TESTS_PKG_SV
package noc_fabric_tests_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_common_env_pkg::*;
  import  noc_fabric_env_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "noc_fabric_test_base.svh"
  `include  "noc_fabric_sample_test.svh"
  `include  "noc_fabric_stress_access_test.svh"
  `include  "noc_fabric_random_test.svh"
endpackage
`endif

