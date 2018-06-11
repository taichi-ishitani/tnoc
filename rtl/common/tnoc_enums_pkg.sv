`ifndef TNOC_ENUMS_PKG_SV
`define TNOC_ENUMS_PKG_SV
package tnoc_enums_pkg;
  typedef enum logic [7:0] {
    TNOC_READ               = 'b001_00000,
    TNOC_POSTED_WRITE       = 'b010_00000,
    TNOC_NON_POSTED_WRITE   = 'b011_00000,
    TNOC_RESPONSE           = 'b100_00000,
    TNOC_RESPONSE_WITH_DATA = 'b110_00000,
    TNOC_INVALID_PACKET     = 'b000_00000
  } tnoc_packet_type;

  typedef enum logic {
    TNOC_X_Y_ROUTING = 'b0,
    TNOC_Y_X_ROUTING = 'b1
  } tnoc_routing_mode;

  typedef enum logic [1:0] {
    TNOC_FIXED_BURST        = 'b00,
    TNOC_INCREMENTING_BURST = 'b01,
    TNOC_WRAPPING_BURST     = 'b10
  } tnoc_burst_type;

  typedef enum logic [1:0] {
    TNOC_OKAY          = 'b00,
    TNOC_EXOKAY        = 'b01,
    TNOC_SLAVE_ERROR   = 'b10,
    TNOC_DECODE_ERROR  = 'b11
  } tnoc_response_status;

  typedef enum logic {
    TNOC_HEADER_FLIT  = 'b0,
    TNOC_PAYLOAD_FLIT = 'b1
  } tnoc_flit_type;
endpackage
`endif
