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

typedef logic [CONFIG.vc_width-1:0] tnoc_vc;

typedef logic [CONFIG.tag_width-1:0]  tnoc_tag;

typedef logic [CONFIG.length_width-1:0] tnoc_length;

typedef enum logic {
  TNOC_X_Y_ROUTING = 'b0,
  TNOC_Y_X_ROUTING = 'b1
} tnoc_routing_mode;

typedef logic [CONFIG.address_width-1:0]  tnoc_address;

typedef enum logic [1:0] {
  tnoc_OKAY          = 'b00,
  tnoc_EXOKAY        = 'b01,
  tnoc_SLAVE_ERROR   = 'b10,
  tnoc_DECODE_ERROR  = 'b11
} tnoc_response_status;

localparam  int LOWER_ADDRESS_WIDTH = $clog2(CONFIG.data_width / 8);
typedef logic [LOWER_ADDRESS_WIDTH-1:0] tnoc_lower_address;

`define tnoc_packet_header_common_fields \
logic             invalid_destination; \
tnoc_routing_mode routing_mode; \
tnoc_length       length; \
tnoc_tag          tag; \
tnoc_vc           vc; \
tnoc_location_id  source_id; \
tnoc_location_id  destination_id; \
tnoc_packet_type  packet_type;

typedef struct packed {
  `tnoc_packet_header_common_fields
} tnoc_common_header;

typedef struct packed {
  tnoc_address  address;
  `tnoc_packet_header_common_fields
} tnoc_request_header;

typedef struct packed {
  logic                 last_response;
  tnoc_lower_address    lower_address;
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
