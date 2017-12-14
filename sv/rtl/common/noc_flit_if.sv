`ifndef NOC_FLIT_IF_SV
`define NOC_FLIT_IF_SV
interface noc_flit_if
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)();
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic     valid;
  logic     ready;
  noc_flit  flit;

  modport master(
    output  valid,
    input   ready,
    output  flit
  );

  modport slave(
    input   valid,
    output  ready,
    input   flit
  );

  modport monitor(
    input valid,
    input ready,
    input flit
  );
endinterface
`endif
