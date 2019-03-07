module tnoc_axi_master_write_adapter
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG      = TNOC_DEFAULT_CONFIG,
  localparam  int         ID_X_WIDTH  = CONFIG.id_x_width,
  localparam  int         ID_Y_WIDTH  = CONFIG.id_y_width,
  localparam  int         VC_WIDTH    = $clog2(CONFIG.virtual_channels)
)(
  input logic                   clk,
  input logic                   rst_n,
  input logic [ID_X_WIDTH-1:0]  i_id_x,
  input logic [ID_Y_WIDTH-1:0]  i_id_y,
  input logic [VC_WIDTH-1:0]    i_vc,
  input tnoc_routing_mode       i_routing_mode,
  tnoc_axi_write_if.master      axi_if,
  tnoc_flit_if.initiator        flit_out_if,
  tnoc_flit_if.target           flit_in_if
);
  import  tnoc_axi_types_pkg::*;
  `include  "tnoc_packet_flit_macros.svh"
  `include  "tnoc_axi_macros.svh"

  `tnoc_define_packet_and_flit(CONFIG)
  `tnoc_axi_define_types(CONFIG)

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_packet_if #(CONFIG)  request_if();
  tnoc_axi_id               awid;

  assign  axi_if.awvalid            = request_if.header_valid;
  assign  request_if.header_ready   = axi_if.awready;
  assign  axi_if.awid               = awid;
  assign  axi_if.awaddr             = request_if.address;
  assign  axi_if.awlen              = pack_burst_length(request_if.burst_length);
  assign  axi_if.awsize             = tnoc_axi_burst_size'(request_if.burst_size);
  assign  axi_if.awburst            = tnoc_axi_burst_type'(request_if.burst_type);
  assign  axi_if.wvalid             = request_if.payload_valid;
  assign  request_if.payload_ready  = axi_if.wready;
  assign  axi_if.wdata              = request_if.data;
  assign  axi_if.wstrb              = request_if.byte_enable;
  assign  axi_if.wlast              = request_if.payload_last;
  assign  awid.location_id          = request_if.source_id;
  assign  awid.tag                  = request_if.tag;

  tnoc_packet_unpacker #(CONFIG, 1) u_packet_unpacker (
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .flit_in_if     (flit_in_if ),
    .packet_out_if  (request_if )
  );

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  tnoc_packet_if #(CONFIG)  response_if();
  tnoc_axi_id               bid;

  assign  response_if.header_valid        = axi_if.bvalid;
  assign  axi_if.bready                   = response_if.header_ready;
  assign  response_if.packet_type         = TNOC_RESPONSE;
  assign  response_if.destination_id      = bid.location_id;
  assign  response_if.source_id.x         = i_id_x;
  assign  response_if.source_id.y         = i_id_y;
  assign  response_if.vc                  = i_vc;
  assign  response_if.tag                 = bid.tag;
  assign  response_if.routing_mode        = i_routing_mode;
  assign  response_if.invalid_destination = '0;
  assign  response_if.burst_type          = TNOC_FIXED_BURST;
  assign  response_if.burst_length        = '0;
  assign  response_if.burst_size          = '0;
  assign  response_if.address             = '0;
  assign  response_if.packet_status       = tnoc_response_status'(axi_if.bresp);
  assign  response_if.payload_valid       = '0;
  assign  response_if.payload_type        = TNOC_WRITE_PAYLOAD;
  assign  response_if.payload_last        = '0;
  assign  response_if.data                = '0;
  assign  response_if.byte_enable         = '0;
  assign  response_if.payload_status      = TNOC_OKAY;
  assign  response_if.response_last       = '0;
  assign  bid                             = axi_if.bid;

  tnoc_packet_packer #(CONFIG, 1) u_packet_packer (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .packet_in_if (response_if  ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
