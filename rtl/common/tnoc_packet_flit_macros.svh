`ifndef TNOC_PACKET_FLIT_MACROS_SVH
`define TNOC_PACKET_FLIT_MACROS_SVH

//--------------------------------------------------------------
//  Packet Macros
//--------------------------------------------------------------
`define tnoc_define_packet_atom_types(CONFIG) \
typedef logic [CONFIG.id_x_width-1:0] \
tnoc_id_x; \
typedef logic [CONFIG.id_y_width-1:0] \
tnoc_id_y; \
typedef struct packed { \
  tnoc_id_x x; \
  tnoc_id_y y; \
} tnoc_location_id; \
typedef logic [((CONFIG.virtual_channels>1)?$clog2(CONFIG.virtual_channels):1)-1:0] \
tnoc_vc; \
typedef logic [((CONFIG.tags>1)?$clog2(CONFIG.tags):1)-1:0] \
tnoc_tag; \
typedef logic [((CONFIG.max_burst_length>1)?$clog2(CONFIG.max_burst_length):1)-1:0] \
tnoc_packed_burst_length; \
typedef logic [$clog2(CONFIG.max_burst_length+1)-1:0] \
tnoc_unpacked_burst_length; \
typedef logic [((CONFIG.data_width>8)?$clog2($clog2(CONFIG.data_width)-3):1)-1:0] \
tnoc_burst_size; \
typedef logic [CONFIG.address_width-1:0] \
tnoc_address; \
typedef logic [CONFIG.data_width-1:0] \
tnoc_data; \
typedef logic [CONFIG.data_width/8-1:0] \
tnoc_byte_enable;

`define tnoc_packet_header_common_fields \
  logic                             invalid_destination; \
  tnoc_enums_pkg::tnoc_routing_mode routing_mode; \
  tnoc_tag                          tag; \
  tnoc_vc                           vc; \
  tnoc_location_id                  source_id; \
  tnoc_location_id                  destination_id; \
  tnoc_enums_pkg::tnoc_packet_type  packet_type;

`define tnoc_packet_header_request_fields \
  tnoc_address                    address; \
  tnoc_burst_size                 burst_size; \
  tnoc_packed_burst_length        burst_length; \
  tnoc_enums_pkg::tnoc_burst_type burst_type;

`define tnoc_packet_header_response_fields \
  tnoc_enums_pkg::tnoc_response_status  status;

`define tnoc_packet_structs \
typedef struct packed { \
`tnoc_packet_header_common_fields \
} tnoc_common_header; \
typedef struct packed { \
`tnoc_packet_header_request_fields \
`tnoc_packet_header_common_fields \
} tnoc_request_header; \
typedef struct packed { \
`tnoc_packet_header_response_fields \
`tnoc_packet_header_common_fields \
} tnoc_response_header; \
typedef struct packed { \
  tnoc_byte_enable  byte_enable; \
  tnoc_data         data; \
} tnoc_write_payload; \
typedef struct packed { \
  logic                 response_last; \
  tnoc_response_status  status; \
  tnoc_data             data; \
} tnoc_read_payload;

`define tnoc_define_packet_localparams \
localparam  int TNOC_COMMON_HEADER_WIDTH    = $bits(tnoc_common_header); \
localparam  int TNOC_REQUEST_HEADER_WIDTH   = $bits(tnoc_request_header); \
localparam  int TNOC_RESPONSE_HEADER_WIDTH  = $bits(tnoc_response_header); \
localparam  int TNOC_WRITE_PAYLOAD_WIDTH    = $bits(tnoc_write_payload); \
localparam  int TNOC_READ_PAYLOAD_WIDTH     = $bits(tnoc_read_payload); \
localparam  int TNOC_HEADER_WIDTH           = ( \
  TNOC_REQUEST_HEADER_WIDTH > TNOC_RESPONSE_HEADER_WIDTH \
) ? TNOC_REQUEST_HEADER_WIDTH : TNOC_RESPONSE_HEADER_WIDTH; \
localparam  int TNOC_PAYLOAD_WIDTH          = ( \
  TNOC_WRITE_PAYLOAD_WIDTH > TNOC_READ_PAYLOAD_WIDTH \
) ? TNOC_WRITE_PAYLOAD_WIDTH : TNOC_READ_PAYLOAD_WIDTH;

`define tnoc_define_packet_utils(CONFIG) \
function automatic logic is_request_header(tnoc_common_header header); \
  return is_request_packet_type(header.packet_type); \
endfunction \
function automatic logic is_posted_request_header(tnoc_common_header header); \
  return is_posted_request_packet_type(header.packet_type); \
endfunction \
function automatic logic is_non_posted_request_header(tnoc_common_header header); \
  return is_non_posted_request_packet_type(header.packet_type); \
endfunction \
function automatic logic is_response_header(tnoc_common_header header); \
  return is_response_packet_type(header.packet_type); \
endfunction \
function automatic logic is_packet_with_payload(tnoc_common_header header); \
  return is_with_payload_packet_type(header.packet_type); \
endfunction \
function automatic logic is_no_payload_packet(tnoc_common_header header); \
  return is_no_payload_packet_type(header.packet_type); \
endfunction \
function automatic tnoc_packed_burst_length pack_burst_length( \
  tnoc_unpacked_burst_length  unpacked_burst_length \
); \
  return  unpacked_burst_length[$bits(tnoc_packed_burst_length)-1:0]; \
endfunction \
function automatic tnoc_unpacked_burst_length unpack_burst_length( \
  tnoc_packed_burst_length  packed_burst_length \
); \
  if (packed_burst_length == 0) begin \
    return  2**$bits(tnoc_packed_burst_length); \
  end \
  else begin \
    return  packed_burst_length; \
  end \
endfunction

`define tnoc_define_packet(CONFIG) \
`tnoc_define_packet_atom_types(CONFIG) \
`tnoc_packet_structs \
`tnoc_define_packet_localparams \
`tnoc_define_packet_utils(CONFIG)

//--------------------------------------------------------------
//  Flit Macros
//--------------------------------------------------------------
`define tnoc_define_flit_types \
localparam  int TNOC_FLIT_DATA_WIDTH  = ( \
  TNOC_COMMON_HEADER_WIDTH > TNOC_PAYLOAD_WIDTH \
) ? TNOC_COMMON_HEADER_WIDTH : TNOC_PAYLOAD_WIDTH; \
typedef logic [TNOC_FLIT_DATA_WIDTH-1:0]  tnoc_flit_data; \
typedef struct packed { \
  tnoc_flit_data                  data; \
  logic                           tail; \
  logic                           head; \
  tnoc_enums_pkg::tnoc_flit_type  flit_type; \
} tnoc_flit;

`define tnoc_define_flit_utils \
function automatic int calc_request_header_flits(); \
  return (TNOC_REQUEST_HEADER_WIDTH + TNOC_FLIT_DATA_WIDTH - 1) / TNOC_FLIT_DATA_WIDTH; \
endfunction \
function automatic int calc_response_header_flits(); \
  return (TNOC_RESPONSE_HEADER_WIDTH + TNOC_FLIT_DATA_WIDTH - 1) / TNOC_FLIT_DATA_WIDTH; \
endfunction \
function automatic int calc_header_flits(); \
  return (TNOC_HEADER_WIDTH + TNOC_FLIT_DATA_WIDTH - 1) / TNOC_FLIT_DATA_WIDTH; \
endfunction \
function automatic logic is_header_flit(tnoc_flit flit); \
  return (flit.flit_type == TNOC_HEADER_FLIT) ? '1 : '0; \
endfunction \
function automatic logic is_payload_flit(tnoc_flit flit); \
  return (flit.flit_type == TNOC_PAYLOAD_FLIT); \
endfunction \
function automatic logic is_head_flit(tnoc_flit flit); \
  return flit.head; \
endfunction \
function automatic logic is_tail_flit(tnoc_flit flit); \
  return flit.tail; \
endfunction \
function automatic tnoc_common_header get_common_header(tnoc_flit flit); \
  return tnoc_common_header'(flit.data[TNOC_COMMON_HEADER_WIDTH-1:0]); \
endfunction \
function automatic tnoc_write_payload get_write_payload(tnoc_flit flit); \
  return tnoc_write_payload'(flit.data[TNOC_WRITE_PAYLOAD_WIDTH-1:0]); \
endfunction \
function automatic tnoc_read_payload get_read_payload(tnoc_flit flit); \
  return tnoc_read_payload'(flit.data[TNOC_READ_PAYLOAD_WIDTH-1:0]); \
endfunction

`define tnoc_define_flit \
`tnoc_define_flit_types \
`tnoc_define_flit_utils

//--------------------------------------------------------------
//  MISC
//--------------------------------------------------------------
`define tnoc_define_packet_and_flit(CONFIG) \
`tnoc_define_packet(CONFIG) \
`tnoc_define_flit

`endif
