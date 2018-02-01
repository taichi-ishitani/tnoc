typedef enum logic {
  TNOC_HEADER_FLIT  = 'b0,
  TNOC_PAYLOAD_FLIT = 'b1
} tnoc_flit_type;

localparam  int FLIT_DATA_WIDTH = (
  COMMON_HEADER_WIDTH > PAYLOD_WIDTH
) ? COMMON_HEADER_WIDTH : PAYLOD_WIDTH;

typedef logic [FLIT_DATA_WIDTH-1:0] tnoc_flit_data;

typedef struct packed {
  tnoc_flit_data  data;
  logic           tail;
  logic           head;  
tnoc_flit_type  flit_type;
} tnoc_flit;

localparam  int FLIT_WIDTH  = $bits(tnoc_flit);
