import  tnoc_enums_pkg::tnoc_packet_type;
import  tnoc_enums_pkg::TNOC_READ;
import  tnoc_enums_pkg::TNOC_POSTED_WRITE;
import  tnoc_enums_pkg::TNOC_NON_POSTED_WRITE;
import  tnoc_enums_pkg::TNOC_RESPONSE;
import  tnoc_enums_pkg::TNOC_RESPONSE_WITH_DATA;
import  tnoc_enums_pkg::TNOC_INVALID_PACKET;
import  tnoc_enums_pkg::is_valid_packet_type;
import  tnoc_enums_pkg::is_request_packet_type;
import  tnoc_enums_pkg::is_posted_request_packet_type;
import  tnoc_enums_pkg::is_non_posted_request_packet_type;
import  tnoc_enums_pkg::is_response_packet_type;
import  tnoc_enums_pkg::is_no_payload_packet_type;
import  tnoc_enums_pkg::is_with_payload_packet_type;

import  tnoc_enums_pkg::tnoc_routing_mode;
import  tnoc_enums_pkg::TNOC_X_Y_ROUTING;
import  tnoc_enums_pkg::TNOC_Y_X_ROUTING;

import  tnoc_enums_pkg::tnoc_burst_type;
import  tnoc_enums_pkg::TNOC_FIXED_BURST;
import  tnoc_enums_pkg::TNOC_INCREMENTING_BURST;
import  tnoc_enums_pkg::TNOC_WRAPPING_BURST;

import  tnoc_enums_pkg::tnoc_response_status;
import  tnoc_enums_pkg::TNOC_OKAY;
import  tnoc_enums_pkg::TNOC_EXOKAY;
import  tnoc_enums_pkg::TNOC_SLAVE_ERROR;
import  tnoc_enums_pkg::TNOC_DECODE_ERROR;

import  tnoc_enums_pkg::tnoc_payload_type;
import  tnoc_enums_pkg::TNOC_WRITE_PAYLOAD;
import  tnoc_enums_pkg::TNOC_READ_PAYLOAD;
import  tnoc_enums_pkg::is_write_payload;
import  tnoc_enums_pkg::is_read_payload;

typedef logic [CONFIG.id_x_width-1:0] tnoc_id_x;
typedef logic [CONFIG.id_y_width-1:0] tnoc_id_y;

typedef struct packed {
  tnoc_id_x  x;
  tnoc_id_y  y;
} tnoc_location_id;

localparam  int VC_WIDTH  = (CONFIG.virtual_channels == 1) ? 1 : $clog2(CONFIG.virtual_channels);
typedef logic [VC_WIDTH-1:0]  tnoc_vc;

localparam  int TAG_WIDTH = (CONFIG.tags == 1) ? 1 : $clog2(CONFIG.tags);
typedef logic [TAG_WIDTH-1:0] tnoc_tag;

localparam  int PACKED_BURST_LENGTH_WIDTH   = (CONFIG.max_burst_length == 0) ? 1 : $clog2(CONFIG.max_burst_length);
localparam  int UNPACKED_BURST_LENGTH_WIDTH = $clog2(CONFIG.max_burst_length + 1);
typedef logic [PACKED_BURST_LENGTH_WIDTH-1:0]   tnoc_packed_burst_length;
typedef logic [UNPACKED_BURST_LENGTH_WIDTH-1:0] tnoc_unpacked_burst_length;

localparam  int BURST_SIZE_WIDTH  = (
  CONFIG.data_width <= 16
) ? 1 : $clog2($clog2(CONFIG.data_width));
typedef logic [BURST_SIZE_WIDTH-1:0]  tnoc_burst_size;

typedef logic [CONFIG.address_width-1:0]  tnoc_address;

`define tnoc_packet_header_common_fields \
logic             invalid_destination; \
tnoc_routing_mode routing_mode; \
tnoc_tag          tag; \
tnoc_vc           vc; \
tnoc_location_id  source_id; \
tnoc_location_id  destination_id; \
tnoc_packet_type  packet_type;

`define tnoc_packet_header_request_fields \
tnoc_address              address; \
tnoc_burst_size           burst_size; \
tnoc_packed_burst_length  burst_length; \
tnoc_burst_type           burst_type;

`define tnoc_packet_header_response_fields \
tnoc_response_status  status;

typedef struct packed {
  `tnoc_packet_header_common_fields
} tnoc_common_header;

typedef tnoc_common_header  tnoc_common_header_fields;

typedef struct packed {
  `tnoc_packet_header_request_fields
  `tnoc_packet_header_common_fields
} tnoc_request_header;

typedef struct packed {
  `tnoc_packet_header_request_fields
} tnoc_request_header_fields;

typedef struct packed {
  `tnoc_packet_header_response_fields
  `tnoc_packet_header_common_fields
} tnoc_response_header;

typedef struct packed {
  `tnoc_packet_header_response_fields
} tnoc_response_header_fields;

`undef  tnoc_packet_header_common_fields
`undef  tnoc_packet_header_request_fields
`undef  tnoc_packet_header_response_fields

typedef logic [CONFIG.data_width-1:0]   tnoc_data;
typedef logic [CONFIG.data_width/8-1:0] tnoc_byte_enable;

typedef struct packed {
  tnoc_byte_enable byte_enable;
  tnoc_data        data;
} tnoc_write_payload;

typedef struct packed {
  logic                 response_last;
  tnoc_response_status  status;
  tnoc_data             data;
} tnoc_read_payload;

localparam  int COMMON_HEADER_WIDTH   = $bits(tnoc_common_header);
localparam  int REQUEST_HEADER_WIDTH  = $bits(tnoc_request_header);
localparam  int RESPONSE_HEADER_WIDTH = $bits(tnoc_response_header);
localparam  int HEADER_WIDTH          = (
  REQUEST_HEADER_WIDTH > RESPONSE_HEADER_WIDTH
) ? REQUEST_HEADER_WIDTH : RESPONSE_HEADER_WIDTH;
localparam  int WRITE_PAYLOAD_WIDTH   = $bits(tnoc_write_payload);
localparam  int READ_PAYLOAD_WIDTH    = $bits(tnoc_read_payload);
localparam  int PAYLOD_WIDTH          = (
  WRITE_PAYLOAD_WIDTH > READ_PAYLOAD_WIDTH
) ? WRITE_PAYLOAD_WIDTH : READ_PAYLOAD_WIDTH;
