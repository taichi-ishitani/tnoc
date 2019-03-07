module tnoc_axi_master_read_adapter
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG            = TNOC_DEFAULT_CONFIG,
  parameter   bit         READ_INTERLEAVING = 0,
  localparam  int         ID_X_WIDTH        = CONFIG.id_x_width,
  localparam  int         ID_Y_WIDTH        = CONFIG.id_y_width,
  localparam  int         VC_WIDTH          = $clog2(CONFIG.virtual_channels)
)(
  input logic                   clk,
  input logic                   rst_n,
  input logic [ID_X_WIDTH-1:0]  i_id_x,
  input logic [ID_Y_WIDTH-1:0]  i_id_y,
  input logic [VC_WIDTH-1:0]    i_vc,
  input tnoc_routing_mode       i_routing_mode,
  tnoc_axi_read_if.master       axi_if,
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
  tnoc_axi_id               arid;

  assign  axi_if.arvalid            = request_if.header_valid;
  assign  request_if.header_ready   = axi_if.arready;
  assign  axi_if.arid               = arid;
  assign  axi_if.araddr             = request_if.address;
  assign  axi_if.arlen              = pack_burst_length(request_if.burst_length);
  assign  axi_if.arsize             = tnoc_axi_burst_size'(request_if.burst_size);
  assign  axi_if.arburst            = tnoc_axi_burst_type'(request_if.burst_type);
  assign  request_if.payload_ready  = '1;
  assign  arid.location_id          = request_if.source_id;
  assign  arid.tag                  = request_if.tag;

  tnoc_packet_unpacker #(CONFIG, 1) u_packet_unpacker (
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .flit_in_if     (flit_in_if ),
    .packet_out_if  (request_if )
  );

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  localparam  int DATA_WIDTH  = CONFIG.data_width;

  tnoc_packet_if #(CONFIG)  response_if();
  logic                     header_valid;
  logic                     payload_valid;
  logic                     payload_ready;
  tnoc_axi_id               rid;
  logic [DATA_WIDTH-1:0]    rdata;
  tnoc_axi_response         rresp;
  logic                     rlast;
  logic                     header_done;
  logic                     payload_last;

  assign  response_if.header_valid        = (header_valid && (!header_done)) ? '1 : '0;
  assign  response_if.packet_type         = TNOC_RESPONSE_WITH_DATA;
  assign  response_if.destination_id      = rid.location_id;
  assign  response_if.source_id.x         = i_id_x;
  assign  response_if.source_id.y         = i_id_y;
  assign  response_if.vc                  = i_vc;
  assign  response_if.tag                 = rid.tag;
  assign  response_if.routing_mode        = i_routing_mode;
  assign  response_if.invalid_destination = '0;
  assign  response_if.burst_type          = TNOC_FIXED_BURST;
  assign  response_if.burst_length        = '0;
  assign  response_if.burst_size          = '0;
  assign  response_if.address             = '0;
  assign  response_if.packet_status       = TNOC_OKAY;
  assign  response_if.payload_valid       = (payload_valid             && header_done) ? '1 : '0;
  assign  payload_ready                   = (response_if.payload_ready && header_done) ? '1 : '0;
  assign  response_if.payload_type        = TNOC_READ_PAYLOAD;
  assign  response_if.payload_last        = payload_last;
  assign  response_if.data                = rdata;
  assign  response_if.byte_enable         = '0;
  assign  response_if.payload_status      = tnoc_response_status'(rresp);
  assign  response_if.response_last       = rlast;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      header_done <= '0;
    end
    else if (
      response_if.payload_valid &&
      response_if.payload_ready &&
      response_if.payload_last
    ) begin
      header_done <= '0;
    end
    else if (
      response_if.header_valid &&
      response_if.header_ready
    ) begin
      header_done <= '1;
    end
  end

  if (READ_INTERLEAVING) begin : g_read_interleaving
    logic rvalid;
    logic rready;
    assign  header_valid  = rvalid;
    assign  payload_valid = (rvalid && (rlast || axi_if.rvalid)) ? '1 : '0;
    assign  rready        = ((!rvalid) || (payload_valid && payload_ready)) ? '1 : '0;
    assign  axi_if.rready = rready;
    assign  payload_last  = (rlast || (axi_if.rid != rid)) ? '1 : '0;
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        rvalid  <= '0;
        rid     <= '0;
        rdata   <= '0;
        rresp   <= TNOC_AXI_OKAY;
        rlast   <= '0;
      end
      else if (rready) begin
        rvalid  <= axi_if.rvalid;
        rid     <= axi_if.rid;
        rdata   <= axi_if.rdata;
        rresp   <= axi_if.rresp;
        rlast   <= axi_if.rlast;
      end
    end
  end
  else begin : g_no_read_interleaving
    assign  header_valid  = axi_if.rvalid;
    assign  payload_valid = axi_if.rvalid;
    assign  axi_if.rready = payload_ready;
    assign  rid           = axi_if.rid;
    assign  rdata         = axi_if.rdata;
    assign  rresp         = axi_if.rresp;
    assign  rlast         = axi_if.rlast;
    assign  payload_last  = axi_if.rlast;
  end

  tnoc_packet_packer #(CONFIG, 1) u_packet_packer (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .packet_in_if (response_if  ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
