module tnoc_axi_slave_write_adapter
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG      = TNOC_DEFAULT_CONFIG,
  localparam  int         ID_X_WIDTH  = CONFIG.id_x_width,
  localparam  int         ID_Y_WIDTH  = CONFIG.id_y_width,
  localparam  int         VC_WIDTH    = $clog2(CONFIG.virtual_channels)
)(
  input logic                       clk,
  input logic                       rst_n,
  input logic [ID_X_WIDTH-1:0]      i_id_x,
  input logic [ID_Y_WIDTH-1:0]      i_id_y,
  input logic [VC_WIDTH-1:0]        i_vc,
  input tnoc_routing_mode           i_routing_mode,
  tnoc_address_decoer_if.requester  decoder_if,
  tnoc_axi_write_if.slave           axi_if,
  tnoc_flit_if.initiator            flit_out_if,
  tnoc_flit_if.target               flit_in_if
);
  import  tnoc_axi_types_pkg::*;
  `include  "tnoc_packet.svh"
  `include  "tnoc_axi_macros.svh"

  `tnoc_axi_define_types(CONFIG)

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_location_id          destination_id;
  logic                     invalid_destination;
  tnoc_packet_if #(CONFIG)  request_if();
  tnoc_axi_id               awid;

  //  Address Decoding
  assign  decoder_if.address  = axi_if.awaddr;
  assign  destination_id.x    = decoder_if.id_x;
  assign  destination_id.y    = decoder_if.id_y;
  assign  invalid_destination = decoder_if.invalid;

  //  Packing
  assign  request_if.header_valid         = axi_if.awvalid;
  assign  axi_if.awready                  = request_if.header_ready;
  assign  request_if.packet_type          = TNOC_NON_POSTED_WRITE;
  assign  request_if.destination_id       = destination_id;
  assign  request_if.source_id.x          = i_id_x;
  assign  request_if.source_id.y          = i_id_y;
  assign  request_if.vc                   = i_vc;
  assign  request_if.tag                  = awid.tag;
  assign  request_if.routing_mode         = i_routing_mode;
  assign  request_if.invalid_destination  = invalid_destination;
  assign  request_if.burst_type           = tnoc_burst_type'(axi_if.awburst);
  assign  request_if.burst_length         = unpack_burst_length(axi_if.awlen);
  assign  request_if.burst_size           = axi_if.awsize[TNOC_BURST_SIZE_WIDTH-1:0];
  assign  request_if.address              = axi_if.awaddr;
  assign  request_if.packet_status        = TNOC_OKAY;
  assign  request_if.payload_valid        = axi_if.wvalid;
  assign  axi_if.wready                   = request_if.payload_ready;
  assign  request_if.payload_type         = TNOC_WRITE_PAYLOAD;
  assign  request_if.payload_last         = axi_if.wlast;
  assign  request_if.data                 = axi_if.wdata;
  assign  request_if.byte_enable          = axi_if.wstrb;
  assign  request_if.payload_status       = TNOC_OKAY;
  assign  request_if.response_last        = '0;
  assign  awid                            = axi_if.awid;

  tnoc_packet_packer #(CONFIG, 1) u_packet_packer (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .packet_in_if (request_if   ),
    .flit_out_if  (flit_out_if  )
  );

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  tnoc_packet_if #(CONFIG)  response_if();
  tnoc_axi_id               bid;

  assign  axi_if.bvalid             = response_if.header_valid;
  assign  response_if.header_ready  = axi_if.bready;
  assign  axi_if.bid                = bid;
  assign  axi_if.bresp              = tnoc_axi_response'(response_if.packet_status);
  assign  response_if.payload_ready = '1;
  assign  bid.location_id           = '0;
  assign  bid.tag                   = response_if.tag;

  tnoc_packet_unpacker #(CONFIG, 1) u_packet_unpacker (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .flit_in_if     (flit_in_if   ),
    .packet_out_if  (response_if  )
  );
endmodule
