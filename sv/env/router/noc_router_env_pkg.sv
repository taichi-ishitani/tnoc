`ifndef TB_ENV_PKG_SV
`define TB_ENV_PKG_SV
package noc_router_env_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "noc_router_env_configuration.svh"
  `include  "noc_router_env_sequencer.svh"
  `include  "noc_router_env.svh"
endpackage
`endif
