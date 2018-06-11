module tnoc_packet_packer
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_packet_if.target   packet_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_packet_utils.svh"

//--------------------------------------------------------------
//  Flit IF
//--------------------------------------------------------------
  tnoc_flit       header_flit;
  logic           header_flit_valid;
  logic           header_flit_ready;
  logic           header_flit_last;
  tnoc_flit       payload_flit;
  logic           payload_flit_valid;
  logic           payload_flit_ready;
  logic           flit_valid;
  logic           flit_ready;
  logic           flit_ack;
  tnoc_flit       flit;
  tnoc_flit_type  current_flit_type;
  logic           no_payload;

  assign  flit_valid          = (current_flit_type == TNOC_HEADER_FLIT ) ? header_flit_valid : payload_flit_valid;
  assign  flit                = (current_flit_type == TNOC_HEADER_FLIT ) ? header_flit       : payload_flit;
  assign  header_flit_ready   = (current_flit_type == TNOC_HEADER_FLIT ) ? flit_ready        : '0;
  assign  payload_flit_ready  = (current_flit_type == TNOC_PAYLOAD_FLIT) ? flit_ready        : '0;
  assign  flit_ack            = flit_valid & flit_ready;

  assign  flit_out_if.flit  = flit;
  if (CHANNELS == 1) begin : g_single_vc
    assign  flit_out_if.valid = flit_valid;
    assign  flit_ready        = flit_out_if.ready;
  end
  else begin : g_multi_vc
    tnoc_vc vc;
    tnoc_vc vc_latched;

    assign  flit_out_if.valid = assign_flit_valid(flit_valid, vc);
    assign  flit_ready        = flit_out_if.ready[vc];

    assign  vc  = (packet_in_if.header_valid) ? packet_in_if.vc : vc_latched;
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        vc_latched  <= 0;
      end
      else if (packet_in_if.header_valid) begin
        vc_latched  <= packet_in_if.vc;
      end
    end

    function automatic logic [CHANNELS-1:0] assign_flit_valid(
      input logic   flit_valid,
      input tnoc_vc vc
    );
      logic [CHANNELS-1:0]  valid;
      valid     = '0;
      valid[vc] = flit_valid;
      return valid;
    endfunction
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      current_flit_type <= TNOC_HEADER_FLIT;
    end
    else if (flit_ack) begin
      if (flit.tail) begin
        current_flit_type <= TNOC_HEADER_FLIT;
      end
      else if (header_flit_last && (!no_payload)) begin
        current_flit_type <= TNOC_PAYLOAD_FLIT;
      end
    end
  end

//--------------------------------------------------------------
//  Header
//--------------------------------------------------------------
  localparam  int HEADER_FLITS      = (HEADER_WIDTH + FLIT_DATA_WIDTH - 1) / FLIT_DATA_WIDTH;
  localparam  int HEADER_DATA_WIDTH = HEADER_FLITS * FLIT_DATA_WIDTH;

  //  renaming
  tnoc_common_header_fields     common_header_fields;
  tnoc_request_header_fields    request_header_fields;
  tnoc_response_header_fields   response_header_fields;

  assign  common_header_fields.packet_type          = packet_in_if.packet_type;
  assign  common_header_fields.destination_id       = packet_in_if.destination_id;
  assign  common_header_fields.source_id            = packet_in_if.source_id;
  assign  common_header_fields.vc                   = packet_in_if.vc;
  assign  common_header_fields.tag                  = packet_in_if.tag;
  assign  common_header_fields.routing_mode         = packet_in_if.routing_mode;
  assign  common_header_fields.invalid_destination  = packet_in_if.invalid_destination;
  assign  request_header_fields.burst_type          = packet_in_if.burst_type;
  assign  request_header_fields.burst_length        = packet_in_if.burst_length;
  assign  request_header_fields.burst_size          = packet_in_if.burst_size;
  assign  request_header_fields.address             = packet_in_if.address;
  assign  response_header_fields.status             = packet_in_if.status;

  //  packing
  logic [HEADER_DATA_WIDTH-1:0] header_data;

  assign  header_data = pack_header(common_header_fields, request_header_fields, response_header_fields);

  function automatic logic [HEADER_DATA_WIDTH-1:0] pack_header(
    input tnoc_common_header_fields   common_header_fields,
    input tnoc_request_header_fields  request_header_fields,
    input tnoc_response_header_fields response_header_fields
  );
    logic [HEADER_DATA_WIDTH-1:0] header  = '0;
    header[COMMON_HEADER_WIDTH-1:0] = common_header_fields;
    if (is_request_header(tnoc_common_header'(common_header_fields))) begin
      header[REQUEST_HEADER_WIDTH-1:COMMON_HEADER_WIDTH]  = request_header_fields;
    end
    else begin
      header[RESPONSE_HEADER_WIDTH-1:COMMON_HEADER_WIDTH] = response_header_fields;
    end
    return header;
  endfunction

  assign  header_flit_valid     = packet_in_if.header_valid;
  assign  header_flit.flit_type = TNOC_HEADER_FLIT;
  assign  no_payload            = is_packet_without_payload(tnoc_common_header'(common_header_fields));
  if (HEADER_FLITS == 1) begin : g_single_header_flit
    assign  packet_in_if.header_ready = header_flit_ready;
    assign  header_flit.head          = '1;
    assign  header_flit.tail          = no_payload;
    assign  header_flit.data          = header_data;
    assign  header_flit_last          = '1;
  end
  else begin : g_multi_header_flit
    localparam  int COUNTER_WIDTH = $clog2(HEADER_FLITS);

    logic [COUNTER_WIDTH-1:0] flit_count;

    assign  packet_in_if.header_ready = header_flit_ready & header_flit_last;
    assign  header_flit.head          = (flit_count == 0) ? '1 : '0;
    assign  header_flit.tail          = no_payload & header_flit_last;
    assign  header_flit.data          = header_data[flit_count*FLIT_DATA_WIDTH+:FLIT_DATA_WIDTH];
    assign  header_flit_last          = (flit_count == (HEADER_FLITS - 1)) ? '1 : '0;

    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        flit_count  <= 0;
      end
      else if (flit_ack && header_flit_ready) begin
        if (header_flit_last) begin
          flit_count  <= 0;
        end
        else begin
          flit_count  <= flit_count + 1;
        end
      end
    end
  end

//--------------------------------------------------------------
//  Payload
//--------------------------------------------------------------
  assign  payload_flit_valid          = packet_in_if.payload_valid;
  assign  packet_in_if.payload_ready  = payload_flit_ready;
  assign  payload_flit.flit_type      = TNOC_PAYLOAD_FLIT;
  assign  payload_flit.head           = '0;
  assign  payload_flit.tail           = packet_in_if.payload_last;
  assign  payload_flit.data           = pack_payload(packet_in_if.data, packet_in_if.byte_enable);

  function automatic tnoc_flit_data pack_payload(
    input tnoc_data         data,
    input tnoc_byte_enable  byte_enable
  );
    tnoc_payload    payload;
    tnoc_flit_data  flit_data;

    payload.data                = data;
    payload.byte_enable         = byte_enable;
    flit_data                   = '0;
    flit_data[PAYLOD_WIDTH-1:0] = payload;

    return flit_data;
  endfunction
endmodule
