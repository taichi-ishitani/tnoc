`ifndef TNOC_ADDRESS_DECODER_IF_SV
`define TNOC_ADDRESS_DECODER_IF_SV
interface tnoc_address_decoer_if
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)();
  logic [CONFIG.address_width-1:0]  address;
  logic [CONFIG.id_x_width-1:0]     id_x;
  logic [CONFIG.id_y_width-1:0]     id_y;
  logic                             invalid;

  modport requester (
    output  address,
    input   id_x,
    input   id_y,
    input   invalid
  );

  modport decoder (
    input   address,
    output  id_x,
    output  id_y,
    output  invalid
  );

  modport monitor (
    input address,
    input id_x,
    input id_y,
    input invalid
  );
endinterface
`endif
