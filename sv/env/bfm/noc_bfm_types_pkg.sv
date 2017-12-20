`ifndef NOC_BFM_TYPES_PKG_SV
`define NOC_BFM_TYPES_PKG_SV
package noc_bfm_types_pkg;
  `include  "noc_bfm_macro.svh"

  typedef enum bit [7:0] {
    NOC_BFM_READ                = 'b001_00000,
    NOC_BFM_POSTED_WRITE        = 'b010_00000,
    NOC_BFM_NON_POSTED_WRITE    = 'b011_00000,
    NOC_BFM_RESPONSE            = 'b100_00000,
    NOC_BFM_RESPONSE_WITH_DATA  = 'b110_00000
  } noc_bfm_packet_type;

  typedef bit [`NOC_BFM_MAX_ID_X_WIDTH-1:0] noc_bfm_id_x;
  typedef bit [`NOC_BFM_MAX_ID_Y_WIDTH-1:0] noc_bfm_id_y;
  typedef struct packed {
    noc_bfm_id_x  x;
    noc_bfm_id_y  y;
  } noc_bfm_location_id;

  typedef bit [`NOC_BFM_MAX_VC_WIDTH-1:0] noc_bfm_vc;

  typedef bit [`NOC_BFM_MAX_TAG_WIDTH-1:0]  noc_bfm_tag;

  typedef bit [`NOC_BFM_MAX_LENGTH_WIDTH-1:0] noc_bfm_length;

  typedef bit [`NOC_BFM_MAX_ADDRESS_WIDTH-1:0]  noc_bfm_address;

  typedef enum bit [1:0] {
    NOC_BFM_OKAY          = 'b00,
    NOC_BFM_EXOKAY        = 'b01,
    NOC_BFM_SLAVE_ERROR   = 'b10,
    NOC_BFM_DECODE_ERROR  = 'b11
  } noc_bfm_response_status;

  localparam  int NOC_BFM_LOWER_ADDRESS_WIDTH = $clog2(`NOC_BFM_MAX_DATA_WIDTH / 8);

  typedef bit [NOC_BFM_LOWER_ADDRESS_WIDTH-1:0] noc_bfm_lower_address;

  typedef bit noc_bfm_last_response;

  localparam  int NOC_BFM_COMMON_HEADER_WIDTH =
    $bits(noc_bfm_packet_type) +
    $bits(noc_bfm_location_id) +
    $bits(noc_bfm_location_id) +
    $bits(noc_bfm_vc         ) +
    $bits(noc_bfm_tag        ) +
    $bits(noc_bfm_length     );
  localparam  int NOC_BFM_REQUEST_HEADER_WIDTH  =
    NOC_BFM_COMMON_HEADER_WIDTH +
    $bits(noc_bfm_address);
  localparam  int NOC_BFM_RESPONSE_HEADER_WIDTH =
    NOC_BFM_COMMON_HEADER_WIDTH    +
    $bits(noc_bfm_response_status) +
    $bits(noc_bfm_lower_address  ) +
    $bits(noc_bfm_last_response  );
  localparam  int NOC_BFM_HEADER_WIDTH  = (
    NOC_BFM_REQUEST_HEADER_WIDTH > NOC_BFM_RESPONSE_HEADER_WIDTH
  ) ? NOC_BFM_REQUEST_HEADER_WIDTH : NOC_BFM_RESPONSE_HEADER_WIDTH;

  typedef bit [`NOC_BFM_MAX_DATA_WIDTH-1:0]   noc_bfm_data;
  typedef bit [`NOC_BFM_MAX_DATA_WIDTH/8-1:0] noc_bfm_byte_enable;
  typedef struct packed {
    noc_bfm_data        data;
    noc_bfm_byte_enable byte_enable;
  } noc_bfm_payload;

  localparam  int NOC_BFM_PAYLOAD_WIDTH = $bits(noc_bfm_payload);

  typedef enum bit {
    NOC_BFM_HEADER_FLIT,
    NOC_BFM_PAYLOAD_FLIT
  } noc_bfm_flit_type;

  localparam  int NOC_FLIT_DATA_WIDTH = (
    NOC_BFM_HEADER_WIDTH > NOC_BFM_PAYLOAD_WIDTH
  ) ? NOC_BFM_HEADER_WIDTH : NOC_BFM_PAYLOAD_WIDTH;

  typedef bit [NOC_FLIT_DATA_WIDTH-1:0] noc_bfm_flit_data;

  typedef struct packed {
    noc_bfm_flit_type flit_type;
    bit               tail;
    noc_bfm_flit_data data;
  } noc_bfm_flit;
endpackage
`endif
