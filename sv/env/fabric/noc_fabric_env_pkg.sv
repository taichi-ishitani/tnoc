`ifndef NOC_FABRIC_ENV_PKG_SV
`define NOC_FABRIC_ENV_PKG_SV
package noc_fabric_env_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "noc_fabric_env_configuration.svh"
  `include  "noc_fabric_env_sequencer.svh"
  `include  "noc_fabric_env.svh"
endpackage
`endif
