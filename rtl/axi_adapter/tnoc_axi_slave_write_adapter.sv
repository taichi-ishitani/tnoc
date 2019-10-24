module tnoc_axi_slave_write_adapter
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
  tnoc_axi_if.slave_write           axi_if,
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
    decode_result = decoder_if.decode(axi_if.awaddr);
    source_id.x   = i_id_x;
    source_id.y   = i_id_y;

    request_if.header_valid = axi_if.awvalid;
    axi_if.awready          = request_if.header_ready;
    request_if.header       = '{
      packet_type:          TNOC_WRITE,
      destination_id:       decode_result.id,
      source_id:            source_id,
      vc:                   i_vc,
      tag:                  axi_if.awid,
      invalid_destination:  decode_result.decode_error,
      burst_type:           tnoc_burst_type'(axi_if.awburst),
      burst_length:         unpack_burst_length(axi_if.awlen),
      burst_size:           axi_if.awsize,
      address:              axi_if.awaddr,
      status:               TNOC_OKAY
    };
  end

  always_comb begin
    request_if.payload_valid  = axi_if.wvalid;
    axi_if.wready             = request_if.payload_ready;
    request_if.payload_last   = axi_if.wlast;
    request_if.payload        = '{
      data:         axi_if.wdata,
      byte_enable:  axi_if.wstrb,
      status:       TNOC_OKAY,
      last:         axi_if.wlast
    };
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
  tnoc_packet_if #(PACKET_CONFIG) response_if(types);

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

  always_comb begin
    axi_if.bvalid             = response_if.header_valid;
    response_if.header_ready  = axi_if.bready;
    axi_if.bid                = response_if.header.tag;
    axi_if.bresp              = tnoc_axi_response'(response_if.header.status);
  end

  always_comb begin
    response_if.payload_ready = '1;
  end
endmodule
