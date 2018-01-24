typedef enum logic [7:0] {
  NOC_READ                = 'b001_00000,
  NOC_POSTED_WRITE        = 'b010_00000,
  NOC_NON_POSTED_WRITE    = 'b011_00000,
  NOC_RESPONSE            = 'b100_00000,
  NOC_RESPONSE_WITH_DATA  = 'b110_00000
} noc_packet_type;

typedef logic [CONFIG.id_x_width-1:0] noc_id_x;
typedef logic [CONFIG.id_y_width-1:0] noc_id_y;

typedef struct packed {
  noc_id_x  x;
  noc_id_y  y;
} noc_location_id;

typedef logic [CONFIG.vc_width-1:0] noc_vc;

typedef logic [CONFIG.tag_width-1:0]  noc_tag;

typedef logic [CONFIG.length_width-1:0] noc_length;

typedef enum logic {
  NOC_X_Y_ROUTING = 'b0,
  NOC_Y_X_ROUTING = 'b1
} noc_routing_mode;

typedef logic [CONFIG.address_width-1:0]  noc_address;

typedef enum logic [1:0] {
  NOC_OKAY          = 'b00,
  NOC_EXOKAY        = 'b01,
  NOC_SLAVE_ERROR   = 'b10,
  NOC_DECODE_ERROR  = 'b11
} noc_response_status;

localparam  int LOWER_ADDRESS_WIDTH = $clog2(CONFIG.data_width / 8);
typedef logic [LOWER_ADDRESS_WIDTH-1:0] noc_lower_address;

`define noc_packet_header_common_fields \
logic             invalid_destination; \
noc_routing_mode  routing_mode; \
noc_length        length; \
noc_tag           tag; \
noc_vc            vc; \
noc_location_id   source_id; \
noc_location_id   destination_id; \
noc_packet_type   packet_type;

typedef struct packed {
  `noc_packet_header_common_fields
} noc_common_header;

typedef struct packed {
  noc_address address;
  `noc_packet_header_common_fields
} noc_request_header;

typedef struct packed {
  logic               last_response;
  noc_lower_address   lower_address;
  noc_response_status status;
  `noc_packet_header_common_fields
} noc_response_header;

`undef  noc_packet_header_common_fields

typedef logic [CONFIG.data_width-1:0]   noc_data;
typedef logic [CONFIG.data_width/8-1:0] noc_byte_enable;

typedef struct packed {
  noc_byte_enable byte_enable;
  noc_data        data;
} noc_payload;

localparam  int COMMON_HEADER_WIDTH   = $bits(noc_common_header);
localparam  int REQUEST_HEADER_WIDTH  = $bits(noc_request_header);
localparam  int RESPONSE_HEADER_WIDTH = $bits(noc_response_header);
localparam  int HEADER_WIDTH          = (
  REQUEST_HEADER_WIDTH > RESPONSE_HEADER_WIDTH
) ? REQUEST_HEADER_WIDTH : RESPONSE_HEADER_WIDTH;
localparam  int PAYLOD_WIDTH          = $bits(noc_payload);
