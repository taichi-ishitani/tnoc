typedef enum logic [7:0] {
  TNOC_READ               = 'b001_00000,
  TNOC_POSTED_WRITE       = 'b010_00000,
  TNOC_NON_POSTED_WRITE   = 'b011_00000,
  TNOC_RESPONSE           = 'b100_00000,
  TNOC_RESPONSE_WITH_DATA = 'b110_00000
} tnoc_packet_type;

typedef logic [CONFIG.id_x_width-1:0] tnoc_id_x;
typedef logic [CONFIG.id_y_width-1:0] tnoc_id_y;

typedef struct packed {
  tnoc_id_x  x;
  tnoc_id_y  y;
} tnoc_location_id;

localparam  int VC_WIDTH  = (CONFIG.virtual_channels == 1) ? 1 : $clog2(CONFIG.virtual_channels);
typedef logic [VC_WIDTH-1:0]  tnoc_vc;

typedef logic [CONFIG.tag_width-1:0]  tnoc_tag;

typedef enum logic {
  TNOC_X_Y_ROUTING = 'b0,
  TNOC_Y_X_ROUTING = 'b1
} tnoc_routing_mode;

typedef enum logic [1:0] {
  TNOC_FIXED_BURST        = 'b00,
  TNOC_INCREMENTING_BURST = 'b01,
  TNOC_WRAPPING_BURST     = 'b10
} tnoc_burst_type;

typedef logic [CONFIG.burst_length_width-1:0] tnoc_burst_length;

localparam  int BURST_SIZE_WIDTH  = (
  CONFIG.data_width <= 16
) ? 1 : $clog2($clog2(CONFIG.data_width));
typedef logic [BURST_SIZE_WIDTH-1:0]  tnoc_burst_size;

typedef logic [CONFIG.address_width-1:0]  tnoc_address;

typedef enum logic [1:0] {
  TNOC_OKAY          = 'b00,
  TNOC_EXOKAY        = 'b01,
  TNOC_SLAVE_ERROR   = 'b10,
  TNOC_DECODE_ERROR  = 'b11
} tnoc_response_status;

`define tnoc_packet_header_common_fields \
logic             invalid_destination; \
tnoc_routing_mode routing_mode; \
tnoc_tag          tag; \
tnoc_vc           vc; \
tnoc_location_id  source_id; \
tnoc_location_id  destination_id; \
tnoc_packet_type  packet_type;

typedef struct packed {
  `tnoc_packet_header_common_fields
} tnoc_common_header;

typedef struct packed {
  tnoc_address      address;
  tnoc_burst_size   burst_size;
  tnoc_burst_length burst_length;
  tnoc_burst_type   burst_type;
  `tnoc_packet_header_common_fields
} tnoc_request_header;

typedef struct packed {
  tnoc_response_status  status;
  `tnoc_packet_header_common_fields
} tnoc_response_header;

`undef  tnoc_packet_header_common_fields

typedef logic [CONFIG.data_width-1:0]   tnoc_data;
typedef logic [CONFIG.data_width/8-1:0] tnoc_byte_enable;

typedef struct packed {
  tnoc_byte_enable byte_enable;
  tnoc_data        data;
} tnoc_payload;

localparam  int COMMON_HEADER_WIDTH   = $bits(tnoc_common_header);
localparam  int REQUEST_HEADER_WIDTH  = $bits(tnoc_request_header);
localparam  int RESPONSE_HEADER_WIDTH = $bits(tnoc_response_header);
localparam  int HEADER_WIDTH          = (
  REQUEST_HEADER_WIDTH > RESPONSE_HEADER_WIDTH
) ? REQUEST_HEADER_WIDTH : RESPONSE_HEADER_WIDTH;
localparam  int PAYLOD_WIDTH          = $bits(tnoc_payload);
