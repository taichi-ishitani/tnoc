typedef enum logic {
  NOC_HEADER_FLIT   = 'b0,
  NOC_PAYLOAD_FLIT  = 'b1
} noc_flit_type;

localparam  int FLIT_DATA_WIDTH = (
  HEADER_WIDTH > PAYLOD_WIDTH
) ? HEADER_WIDTH : PAYLOD_WIDTH;

typedef logic [FLIT_DATA_WIDTH-1:0] noc_flit_data;

typedef struct packed {
  noc_flit_data data;
  logic         tail;
  noc_flit_type flit_type;
} noc_flit;

localparam  int FLIT_WIDTH  = $bits(noc_flit);
