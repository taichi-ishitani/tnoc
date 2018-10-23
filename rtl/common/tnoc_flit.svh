localparam  int TNOC_FLIT_DATA_WIDTH  = (
  TNOC_COMMON_HEADER_WIDTH > TNOC_PAYLOD_WIDTH
) ? TNOC_COMMON_HEADER_WIDTH : TNOC_PAYLOD_WIDTH;

typedef logic [TNOC_FLIT_DATA_WIDTH-1:0]  tnoc_flit_data;

typedef struct packed {
  tnoc_flit_data  data;
  logic           tail;
  logic           head;
  tnoc_flit_type  flit_type;
} tnoc_flit;

localparam  int TNOC_FLIT_WIDTH = $bits(tnoc_flit);
