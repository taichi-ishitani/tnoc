module tnoc_axi_slave_read_adapter
  import  tnoc_pkg::*,
          tnoc_axi_pkg::*;
#(
  parameter   tnoc_packet_config  PACKET_CONFIG = TNOC_DEFAULT_PACKET_CONFIG,
  localparam  int                 ID_X_WIDTH    = get_id_x_width(PACKET_CONFIG),
  localparam  int                 ID_Y_WIDTH    = get_id_y_width(PACKET_CONFIG),
  localparam  int                 VC_WIDTH      = get_vc_width(PACKET_CONFIG)
)(
  tnoc_types                        types,
  input var logic                   i_clk,
  input var logic                   i_rst_n,
  input var logic [ID_X_WIDTH-1:0]  i_id_x,
  input var logic [ID_Y_WIDTH-1:0]  i_id_y,
  input var logic [VC_WIDTH-1:0]    i_vc,
  tnoc_address_decoder_if.requester decoder_if,
  tnoc_axi_if.slave_read            axi_if,
  tnoc_flit_if.receiver             receiver_if,
  tnoc_flit_if.sender               sender_if
);
  typedef types.tnoc_decode_result  tnoc_decode_result;
  typedef types.tnoc_location_id    tnoc_location_id;

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_decode_result              decode_result;
  tnoc_location_id                source_id;
  tnoc_packet_if #(PACKET_CONFIG) request_if(types);

  always_comb begin
    decode_result = decoder_if.decode(axi_if.araddr);
    source_id.x   = i_id_x;
    source_id.y   = i_id_y;

    request_if.header_valid = axi_if.arvalid;
    axi_if.arready          = request_if.header_ready;
    request_if.header       = '{
      packet_type:          TNOC_READ,
      destination_id:       decode_result.id,
      source_id:            source_id,
      vc:                   i_vc,
      tag:                  axi_if.arid,
      invalid_destination:  decode_result.decode_error,
      burst_type:           tnoc_burst_type'(axi_if.arburst),
      burst_length:         unpack_burst_length(axi_if.arlen),
      burst_size:           axi_if.arsize,
      address:              axi_if.araddr,
      status:               TNOC_OKAY
    };
  end

  always_comb begin
    request_if.payload_valid  = '0;
    request_if.payload_last   = '0;
    request_if.payload        = '0;
  end

  tnoc_packet_serializer #(
    .PACKET_CONFIG  (PACKET_CONFIG    ),
    .CHANNELS       (1                ),
    .PORT_TYPE      (TNOC_LOCAL_PORT  )
  ) u_serializer (
    .types      (types      ),
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .packet_if  (request_if ),
    .sender_if  (sender_if  )
  );

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  tnoc_packet_if #(PACKET_CONFIG)           response_if(types);
  logic                                     response_busy;
  logic [get_tag_width(PACKET_CONFIG)-1:0]  rid;

  tnoc_packet_deserializer #(
    .PACKET_CONFIG  (PACKET_CONFIG    ),
    .CHANNELS       (1                ),
    .PORT_TYPE      (TNOC_LOCAL_PORT  )
  ) u_deserializer (
    .types        (types        ),
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .receiver_if  (receiver_if  ),
    .packet_if    (response_if  )
  );

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_busy <= '0;
    end
    else if (
      response_if.get_payload_ack() &&
      response_if.payload_last
    ) begin
      response_busy <= '0;
    end
    else if (
      response_if.get_header_ack()
    ) begin
      response_busy <= '1;
    end
  end

  always_ff @(posedge i_clk) begin
    if (response_if.get_header_ack()) begin
      rid <= response_if.header.tag;
    end
  end

  always_comb begin
    response_if.header_ready  = ~response_busy;
  end

  always_comb begin
    axi_if.rvalid             = (response_busy) ? response_if.payload_valid : '0;
    response_if.payload_ready = axi_if.rready;
    axi_if.rid                = rid;
    axi_if.rdata              = response_if.payload.data;
    axi_if.rresp              = tnoc_axi_response'(response_if.payload.status);
    axi_if.rlast              = response_if.payload.last;
  end
endmodule
