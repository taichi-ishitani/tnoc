`ifndef NOC_COMMON_ENV_PKG_SV
`define NOC_COMMON_ENV_PKG_SV
package noc_common_env_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `uvm_analysis_imp_decl(_tx)
  `uvm_analysis_imp_decl(_rx)

  `include  "noc_packet_scoreboard.svh"
endpackage
`endif
