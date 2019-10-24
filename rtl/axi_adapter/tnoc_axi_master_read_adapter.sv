module tnoc_axi_master_read_adapter
  import  tnoc_pkg::*,
          tnoc_axi_pkg::*;
#(
  parameter   tnoc_packet_config  PACKET_CONFIG     = TNOC_DEFAULT_PACKET_CONFIG,
  parameter   bit                 READ_INTERLEAVING = 0,
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
  tnoc_axi_if.master_read           axi_if,
  tnoc_flit_if.receiver             receiver_if,
  tnoc_flit_if.sender               sender_if
);
  typedef types.tnoc_location_id    tnoc_location_id;
  typedef types.tnoc_tag            tnoc_tag;

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_packet_if #(PACKET_CONFIG) request_if(types);

  always_comb begin
    axi_if.arvalid          = request_if.header_valid;
    request_if.header_ready = axi_if.arready;
    axi_if.arid             = {request_if.header.source_id, request_if.header.tag};
    axi_if.araddr           = request_if.header.address;
    axi_if.arlen            = pack_burst_length(request_if.header.burst_length);
    axi_if.arsize           = tnoc_axi_burst_size'(request_if.header.burst_size);
    axi_if.arburst          = tnoc_axi_burst_type'(request_if.header.burst_type);
  end

  always_comb begin
    request_if.payload_ready  = '1;
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
  localparam  int DATA_WIDTH    = PACKET_CONFIG.data_width;
  localparam  int AXI_ID_WIDTH  = get_id_width(PACKET_CONFIG);

  tnoc_packet_if #(PACKET_CONFIG) response_if(types);
  tnoc_location_id                source_id;
  logic                           header_valid;
  logic                           payload_valid;
  logic                           payload_ready;
  logic                           payload_last;
  logic                           header_done;
  logic [AXI_ID_WIDTH-1:0]        rid;
  logic [DATA_WIDTH-1:0]          rdata;
  tnoc_axi_response               rresp;
  logic                           rlast;

  always_comb begin
    source_id.x = i_id_x;
    source_id.y = i_id_y;

    response_if.header_valid  = (!header_done) ? header_valid : '0;
    response_if.header        = '{
      packet_type:          TNOC_RESPONSE_WITH_DATA,
      destination_id:       get_destination_id(rid),
      source_id:            source_id,
      vc:                   i_vc,
      tag:                  get_tag(rid),
      invalid_destination:  '0,
      burst_type:           TNOC_FIXED_BURST,
      burst_length:         '0,
      burst_size:           '0,
      address:              '0,
      status:               TNOC_OKAY
    };
  end

  always_comb begin
    response_if.payload_valid = (header_done) ? payload_valid             : '0;
    payload_ready             = (header_done) ? response_if.payload_ready : '0;
    response_if.payload_last  = payload_last;
    response_if.payload       = '{
      data:         rdata,
      byte_enable:  '0,
      status:       tnoc_response_status'(rresp),
      last:         rlast
    };
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      header_done <= '0;
    end
    else if (response_if.get_payload_ack()) begin
      if (response_if.payload_last) begin
        header_done <= '0;
      end
    end
    else if (response_if.get_header_ack()) begin
      header_done <= '1;
    end
  end

  function automatic tnoc_location_id get_destination_id(
    logic [AXI_ID_WIDTH-1:0]  rid
  );
    tnoc_location_id  destination_id;
    tnoc_tag          tag;
    {destination_id, tag} = rid;
    return destination_id;
  endfunction

  function automatic tnoc_tag get_tag(
    logic [AXI_ID_WIDTH-1:0]  rid
  );
    tnoc_location_id  destination_id;
    tnoc_tag          tag;
    {destination_id, tag} = rid;
    return tag;
  endfunction

  if (READ_INTERLEAVING) begin : g_read_interleaving
    logic rvalid;

    always_comb begin
      if (rvalid) begin
        header_valid  = '1;
        payload_valid = (rlast || axi_if.rvalid) ? '1 : '0;
      end
      else begin
        header_valid  = '0;
        payload_valid = '0;
      end
    end

    always_comb begin
      if (rlast) begin
        payload_last  = '1;
      end
      else if (rid != axi_if.rid) begin
        payload_last  = '1;
      end
      else begin
        payload_last  = '0;
      end
    end

    always_comb begin
      if (!rvalid) begin
        axi_if.rready = '1;
      end
      else if (response_if.get_payload_ack()) begin
        axi_if.rready = '1;
      end
      else begin
        axi_if.rready = '0;
      end
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) begin
        rvalid  <= '0;
      end
      else if (axi_if.rready) begin
        rvalid  <= axi_if.rvalid;
      end
    end

    always_ff @(posedge i_clk) begin
      if (axi_if.rready) begin
        rid   <= axi_if.rid;
        rdata <= axi_if.rdata;
        rresp <= axi_if.rresp;
        rlast <= axi_if.rlast;
      end
    end
  end
  else begin : g_no_read_interleaving
    always_comb begin
      header_valid  = axi_if.rvalid;
      payload_valid = axi_if.rvalid;
      axi_if.rready = payload_ready;
      rid           = axi_if.rid;
      rdata         = axi_if.rdata;
      rresp         = axi_if.rresp;
      rlast         = axi_if.rlast;
      payload_last  = axi_if.rlast;
    end
  end

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
