`ifndef TNOC_PKG_SV
`define TNOC_PKG_SV

`ifndef TNOC_DEFAULT_ADDRESS_WIDTH
  `define TNOC_DEFAULT_ADDRESS_WIDTH  64
`endif

`ifndef TNOC_DEFAULT_DATA_WIDTH
  `define TNOC_DEFAULT_DATA_WIDTH 256
`endif

`ifndef TNOC_DEFAULT_SIZE_X
  `define TNOC_DEFAULT_SIZE_X 3
`endif

`ifndef TNOC_DEFAULT_SIZE_Y
  `define TNOC_DEFAULT_SIZE_Y 3
`endif

`ifndef TNOC_DEFAULT_VIRTUAL_CHANNELS
  `define TNOC_DEFAULT_VIRTUAL_CHANNELS 2
`endif

`ifndef TNOC_DEFAULT_TAGS
  `define TNOC_DEFAULT_TAGS 256
`endif

`ifndef TNOC_DEFAULT_MAX_BURST_LENGTH
  `define TNOC_DEFAULT_MAX_BURST_LENGTH 256
`endif

`ifndef TNOC_DEFAULT_FIFO_DEPTH
  `define TNOC_DEFAULT_FIFO_DEPTH 8
`endif

package tnoc_pkg;
//--------------------------------------------------------------
//  Configuration
//--------------------------------------------------------------
  typedef struct packed {
    int unsigned  address_width;
    int unsigned  data_width;
    int unsigned  size_x;
    int unsigned  size_y;
    int unsigned  virtual_channels;
    int unsigned  tags;
    int unsigned  max_burst_length;
  } tnoc_packet_config;

  localparam  tnoc_packet_config  TNOC_DEFAULT_PACKET_CONFIG  = '{
    address_width:    `TNOC_DEFAULT_ADDRESS_WIDTH,
    data_width:       `TNOC_DEFAULT_DATA_WIDTH,
    size_x:           `TNOC_DEFAULT_SIZE_X,
    size_y:           `TNOC_DEFAULT_SIZE_Y,
    virtual_channels: `TNOC_DEFAULT_VIRTUAL_CHANNELS,
    tags:             `TNOC_DEFAULT_TAGS,
    max_burst_length: `TNOC_DEFAULT_MAX_BURST_LENGTH
  };

  function automatic int clog2(bit [31:0] n);
    int result;

    result  = 0;
    for (int i = 31;i >= 0;--i) begin
      if (n[i]) begin
        result  = i;
        break;
      end
    end

    if ((2**result) == n) begin
      return result;
    end
    else begin
      return result + 1;
    end
  endfunction

  function automatic int get_id_x_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.size_x >= 2) begin
      return clog2(packet_config.size_x);
    end
    else begin
      return 1;
    end
  endfunction

  function automatic int get_id_y_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.size_y >= 2) begin
      return clog2(packet_config.size_y);
    end
    else begin
      return 1;
    end
  endfunction

  function automatic int get_location_id_width(
    tnoc_packet_config  packet_config
  );
    return get_id_x_width(packet_config) + get_id_y_width(packet_config);
  endfunction

  function automatic int get_vc_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.virtual_channels >= 2) begin
      return clog2(packet_config.virtual_channels);
    end
    else begin
      return 1;
    end
  endfunction

  function automatic int get_tag_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.tags >= 2) begin
      return clog2(packet_config.tags);
    end
    else begin
      return 1;
    end
  endfunction

  function automatic int get_burst_length_width(
    tnoc_packet_config  packet_config
  );
    return clog2(packet_config.max_burst_length + 1);
  endfunction

  function automatic int get_packed_burst_length_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.max_burst_length >= 2) begin
      return clog2(packet_config.max_burst_length);
    end
    else begin
      return 1;
    end
  endfunction

  function automatic int get_burst_size_width(
    tnoc_packet_config  packet_config
  );
    if (packet_config.data_width >= 16) begin
      return clog2(clog2(packet_config.data_width) - 3);
    end
    else begin
      return 1;
    end
  endfunction

//--------------------------------------------------------------
//  Packet/Flit
//--------------------------------------------------------------
  typedef enum logic [7:0] {
    TNOC_INVALID_PACKET     = 'b000_00000,
    TNOC_READ               = 'b001_00000,
    TNOC_WRITE              = 'b011_00000,
    TNOC_POSTED_WRITE       = 'b010_00000,
    TNOC_RESPONSE           = 'b100_00000,
    TNOC_RESPONSE_WITH_DATA = 'b110_00000
  } tnoc_packet_type;

  typedef enum logic [1:0] {
    TNOC_FIXED_BURST    = 2'b00,
    TNOC_NORMAL_BURST   = 2'b01,
    TNOC_WRAPPING_BURST = 2'b10
  } tnoc_burst_type;

  typedef enum logic [1:0] {
    TNOC_OKAY         = 2'b00,
    TNOC_EXOKAY       = 2'b01,
    TNOC_SLAVE_ERROR  = 2'b10,
    TNOC_DECODE_ERROR = 2'b11
  } tnoc_response_status;

  typedef enum logic {
    TNOC_HEADER_FLIT  = 1'b0,
    TNOC_PAYLOAD_FLIT = 1'b1
  } tnoc_flit_type;

  function automatic logic is_request_packet_type(tnoc_packet_type packet_type);
    return ((packet_type != TNOC_INVALID_PACKET) && (packet_type[7] == '0)) ? '1 : '0;
  endfunction

  function automatic logic is_response_packet_type(tnoc_packet_type packet_type);
    return ((packet_type != TNOC_INVALID_PACKET) && (packet_type[7] == '1)) ? '1 : '0;
  endfunction

  function automatic logic is_packet_with_payload_type(tnoc_packet_type packet_type);
    return ((packet_type != TNOC_INVALID_PACKET) && (packet_type[6] == '1)) ? '1 : '0;
  endfunction

  function automatic logic is_header_only_packet_type(tnoc_packet_type packet_type);
    return ((packet_type != TNOC_INVALID_PACKET) && (packet_type[6] == '0)) ? '1 : '0;
  endfunction

  function automatic logic is_posted_request_packet_type(tnoc_packet_type packet_type);
    return (is_request_packet_type(packet_type) && (packet_type[5] == '0)) ? '1 : '0;
  endfunction

  function automatic logic is_non_posted_request_packet_type(tnoc_packet_type packet_type);
    return (is_request_packet_type(packet_type) && (packet_type[5] == '1)) ? '1 : '0;
  endfunction

  function automatic int get_common_header_field_width(
    tnoc_packet_config  packet_config
  );
    int width;
    width = 0;
    width += $bits(tnoc_packet_type);               //  packet_type
    width += get_location_id_width(packet_config);  //  destination_id
    width += get_location_id_width(packet_config);  //  source_id
    width += get_vc_width(packet_config);           //  vc
    width += get_tag_width(packet_config);          //  tag
    width += 1;                                     //  invalid_destination
    return width;
  endfunction

  function automatic int get_request_header_width(
    tnoc_packet_config  packet_config
  );
    int width;
    width = 0;
    width += get_common_header_field_width(packet_config);  //  common fields
    width += $bits(tnoc_burst_type);                        //  burst.burst_type
    width += get_packed_burst_length_width(packet_config);  //  burst.length
    width += get_burst_size_width(packet_config);           //  burst.size
    width += packet_config.address_width;                   //  address
    return width;
  endfunction

  function automatic int get_response_header_width(
    tnoc_packet_config  packet_config
  );
    int width;
    width = 0;
    width += get_common_header_field_width(packet_config);  //  common fields
    width += $bits(tnoc_response_status);                   //  status
    return width;
  endfunction

  function automatic int get_header_width(
    tnoc_packet_config  packet_config
  );
    int width;

    width = 0;
    if (get_request_header_width(packet_config) > width) begin
      width = get_request_header_width(packet_config);
    end
    if (get_response_header_width(packet_config) > width) begin
      width = get_response_header_width(packet_config);
    end

    return width;
  endfunction

  function automatic int get_request_payload_width(
    tnoc_packet_config  packet_config
  );
    int width;
    width = 0;
    width += packet_config.data_width;      //  data
    width += packet_config.data_width / 8;  //  byte_enable
    return width;
  endfunction

  function automatic int get_response_payload_width(
    tnoc_packet_config  packet_config
  );
    int width;
    width = 0;
    width += packet_config.data_width;    //  data
    width += $bits(tnoc_response_status); //  status
    width += 1;                           //  last
    return width;
  endfunction

  function automatic int get_payload_width(
    tnoc_packet_config  packet_config
  );
    int width;

    width = 0;
    if (get_request_payload_width(packet_config) > width) begin
      width = get_request_payload_width(packet_config);
    end
    if (get_response_payload_width(packet_config) > width) begin
      width = get_response_payload_width(packet_config);
    end

    return width;
  endfunction

  function automatic int get_flit_data_width(
    tnoc_packet_config  packet_config
  );
    int width;

    width = 0;
    if (get_common_header_field_width(packet_config) > width) begin
      width = get_common_header_field_width(packet_config);
    end
    if (get_payload_width(packet_config) > width) begin
      width = get_payload_width(packet_config);
    end

    return width;
  endfunction

  function automatic int get_flit_width(
    tnoc_packet_config  packet_config
  );
    int width;

    width = 0;
    width += $bits(tnoc_flit_type);               //  flit_type
    width += 1;                                   //  head
    width += 1;                                   //  tail
    width += get_flit_data_width(packet_config);  //  data

    return width;
  endfunction


  function automatic int get_request_header_flits(
    tnoc_packet_config  packet_config
  );
    int header_width;
    int flit_width;
    header_width  = get_request_header_width(packet_config);
    flit_width    = get_flit_data_width(packet_config);
    return (header_width + flit_width - 1) / flit_width;
  endfunction

  function automatic int get_response_header_flits(
    tnoc_packet_config  packet_config
  );
    int header_width;
    int flit_width;
    header_width  = get_response_header_width(packet_config);
    flit_width    = get_flit_data_width(packet_config);
    return (header_width + flit_width - 1) / flit_width;
  endfunction

  function automatic int get_header_flits(
    tnoc_packet_config  packet_config
  );
    int flits;

    flits = 0;
    if (get_request_header_flits(packet_config) > flits) begin
      flits = get_request_header_flits(packet_config);
    end
    if (get_response_header_flits(packet_config) > flits) begin
      flits = get_response_header_flits(packet_config);
    end

    return flits;
  endfunction

//--------------------------------------------------------------
//  ETC
//--------------------------------------------------------------
  typedef enum bit {
    TNOC_LOCAL_PORT     = 1'b0,
    TNOC_INTERNAL_PORT  = 1'b1
  } tnoc_port_type;

  function automatic bit is_local_port(tnoc_port_type port_type);
    return (port_type == TNOC_LOCAL_PORT);
  endfunction

  function automatic bit is_interna_port(tnoc_port_type port_type);
    return (port_type == TNOC_INTERNAL_PORT);
  endfunction

  function automatic int get_port_flit_width(
    tnoc_packet_config  packet_config,
    tnoc_port_type      port_type,
    int                 channels
  );
    int flit_width;
    flit_width  = get_flit_width(packet_config);
    if (is_local_port(port_type)) begin
      return channels * flit_width;
    end
    else begin
      return flit_width;
    end
  endfunction
endpackage
`endif
