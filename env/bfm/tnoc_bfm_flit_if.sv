`ifndef TNOC_BFM_FLIT_IF_SV
`define TNOC_BFM_FLIT_IF_SV
interface tnoc_bfm_flit_if (
  input logic clk,
  input logic rst_n
);
  import  tnoc_bfm_types_pkg::tnoc_bfm_flit;

  bit           valid;
  bit           ready;
  tnoc_bfm_flit flit;
  bit           vc_available;

  clocking master_cb @(posedge clk);
    output  valid;
    input   ready;
    output  flit;
    input   vc_available;
  endclocking

  clocking slave_cb @(posedge clk);
    input   valid;
    output  ready;
    input   flit;
    output  vc_available;
  endclocking

  clocking monitor_cb @(posedge clk);
    input valid;
    input ready;
    input flit;
    input vc_available;
  endclocking

  modport initiator(
    output  valid,
    input   ready,
    output  flit,
    input   vc_available
  );

  modport target(
    input   valid,
    output  ready,
    input   flit,
    output  vc_available
  );
endinterface
`endif
