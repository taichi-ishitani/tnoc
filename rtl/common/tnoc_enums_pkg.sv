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

  function automatic logic is_valid_packet_type(input tnoc_packet_type packet_type);
    return (packet_type != TNOC_INVALID_PACKET) ? '1 : '0;
  endfunction

  function automatic logic is_request_packet_type(input tnoc_packet_type packet_type);
    return (is_valid_packet_type(packet_type) && (!packet_type[7])) ? '1 : '0;
  endfunction

  function automatic logic is_posted_request_packet_type(input tnoc_packet_type packet_type);
    return (is_request_packet_type(packet_type) && (!packet_type[5])) ? '1 : '0;
  endfunction

  function automatic logic is_non_posted_request_packet_type(input tnoc_packet_type packet_type);
    return (is_request_packet_type(packet_type) && packet_type[5]) ? '1 : '0;
  endfunction

  function automatic logic is_response_packet_type(input tnoc_packet_type packet_type);
    return (is_valid_packet_type(packet_type) && packet_type[7]) ? '1 : '0;
  endfunction

  function automatic logic is_no_payload_packet_type(input tnoc_packet_type packet_type);
    return (is_valid_packet_type(packet_type) && (!packet_type[6])) ? '1 : '0;
  endfunction

  function automatic logic is_with_payload_packet_type(input tnoc_packet_type packet_type);
    return (is_valid_packet_type(packet_type) && packet_type[6]) ? '1 : '0;
  endfunction

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
    TNOC_WRITE_PAYLOAD  = 'b0,
    TNOC_READ_PAYLOAD   = 'b1
  } tnoc_payload_type;

  function automatic logic is_write_payload(input tnoc_payload_type payload_type);
    return (payload_type == TNOC_WRITE_PAYLOAD) ? '1 : '0;
  endfunction

  function automatic logic is_read_payload(input tnoc_payload_type payload_type);
    return (payload_type == TNOC_READ_PAYLOAD) ? '1 : '0;
  endfunction

  typedef enum logic {
    TNOC_HEADER_FLIT  = 'b0,
    TNOC_PAYLOAD_FLIT = 'b1
  } tnoc_flit_type;

  typedef enum bit {
    TNOC_LOCAL_PORT     = 0,
    TNOC_INTERNAL_PORT  = 1
  } tnoc_port_type;

  function automatic bit is_local_port(input tnoc_port_type port_type);
    return (port_type == TNOC_LOCAL_PORT) ? 1 : 0;
  endfunction

  function automatic bit is_internal_port(input tnoc_port_type port_type);
    return (port_type == TNOC_INTERNAL_PORT) ? 1 : 0;
  endfunction
endpackage
`endif
