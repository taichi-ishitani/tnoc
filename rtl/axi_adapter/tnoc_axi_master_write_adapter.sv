module tnoc_axi_master_write_adapter
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
  tnoc_axi_if.master_write          axi_if,
  tnoc_flit_if.receiver             receiver_if,
  tnoc_flit_if.sender               sender_if
);
  typedef types.tnoc_location_id  tnoc_location_id;
  typedef types.tnoc_tag          tnoc_tag;

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_packet_if #(PACKET_CONFIG) request_if(types);

  always_comb begin
    axi_if.awvalid          = request_if.header_valid;
    request_if.header_ready = axi_if.awready;
    axi_if.awid             = {request_if.header.source_id, request_if.header.tag};
    axi_if.awaddr           = request_if.header.address;
    axi_if.awlen            = pack_burst_length(request_if.header.burst_length);
    axi_if.awsize           = tnoc_axi_burst_size'(request_if.header.burst_size);
    axi_if.awburst          = tnoc_axi_burst_type'(request_if.header.burst_type);
  end

  always_comb begin
    axi_if.wvalid             = request_if.payload_valid;
    request_if.payload_ready  = axi_if.wready;
    axi_if.wdata              = request_if.payload.data;
    axi_if.wstrb              = request_if.payload.byte_enable;
    axi_if.wlast              = request_if.payload_last;
  end

  tnoc_packet_deserializer #(
    .PACKET_CONFIG  (PACKET_CONFIG  ),
    .CHANNELS       (1              )
  ) u_deserializer (
    .types        (types        ),
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .receiver_if  (receiver_if  ),
    .packet_if    (request_if   )
  );

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  tnoc_packet_if #(PACKET_CONFIG) response_if(types);
  tnoc_location_id                source_id;

  always_comb begin
    source_id.x = i_id_x;
    source_id.y = i_id_y;

    response_if.header_valid  = axi_if.bvalid;
    axi_if.bready             = response_if.header_ready;
    response_if.header        = '{
      packet_type:          TNOC_RESPONSE,
      destination_id:       get_destination_id(axi_if.bid),
      source_id:            source_id,
      vc:                   i_vc,
      tag:                  get_tag(axi_if.bid),
      invalid_destination:  '0,
      burst_type:           TNOC_FIXED_BURST,
      burst_length:         '0,
      burst_size:           '0,
      address:              '0,
      status:               tnoc_response_status'(axi_if.bresp)
    };
  end

  always_comb begin
    response_if.payload_valid = '0;
    response_if.payload_last  = '0;
    response_if.payload       = '0;
  end

  function automatic tnoc_location_id get_destination_id(
    logic [get_id_width(PACKET_CONFIG)-1:0] id
  );
    tnoc_location_id  destination_id;
    tnoc_tag          tag;
    {destination_id, tag} = id;
    return destination_id;
  endfunction

  function automatic tnoc_tag get_tag(
    logic [get_id_width(PACKET_CONFIG)-1:0] id
  );
    tnoc_location_id  destination_id;
    tnoc_tag          tag;
    {destination_id, tag} = id;
    return tag;
  endfunction

  tnoc_packet_serializer #(
    .PACKET_CONFIG  (PACKET_CONFIG  ),
    .CHANNELS       (1              )
  ) u_serializer (
    .types      (types        ),
    .i_clk      (i_clk        ),
    .i_rst_n    (i_rst_n      ),
    .packet_if  (response_if  ),
    .sender_if  (sender_if    )
  );
endmodule
