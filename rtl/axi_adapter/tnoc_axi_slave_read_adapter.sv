module tnoc_axi_slave_read_adapter
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
  tnoc_address_decoer_if.requester  decoder_if,
  tnoc_axi_read_if.slave            axi_if,
  tnoc_flit_if.initiator            flit_out_if,
  tnoc_flit_if.target               flit_in_if
);
  import  tnoc_axi_types_pkg::*;
  `include  "tnoc_packet_flit_macros.svh"
  `include  "tnoc_axi_macros.svh"

  `tnoc_define_packet_and_flit(CONFIG)
  `tnoc_axi_define_types(CONFIG)

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  tnoc_location_id          destination_id;
  logic                     invalid_destination;
  tnoc_packet_if #(CONFIG)  request_if();
  tnoc_axi_id               arid;

  //  Address Decoding
  assign  decoder_if.address  = axi_if.araddr;
  assign  destination_id.x    = decoder_if.id_x;
  assign  destination_id.y    = decoder_if.id_y;
  assign  invalid_destination = decoder_if.invalid;

  //  Packing
  assign  request_if.header_valid         = axi_if.arvalid;
  assign  axi_if.arready                  = request_if.header_ready;
  assign  request_if.packet_type          = TNOC_READ;
  assign  request_if.destination_id       = destination_id;
  assign  request_if.source_id.x          = i_id_x;
  assign  request_if.source_id.y          = i_id_y;
  assign  request_if.vc                   = i_vc;
  assign  request_if.tag                  = arid.tag;
  assign  request_if.invalid_destination  = invalid_destination;
  assign  request_if.burst_type           = tnoc_burst_type'(axi_if.arburst);
  assign  request_if.burst_length         = unpack_burst_length(axi_if.arlen);
  assign  request_if.burst_size           = axi_if.arsize[$bits(tnoc_burst_size)-1:0];
  assign  request_if.address              = axi_if.araddr;
  assign  request_if.packet_status        = TNOC_OKAY;
  assign  request_if.payload_valid        = '0;
  assign  request_if.payload_type         = TNOC_READ_PAYLOAD;
  assign  request_if.payload_last         = '0;
  assign  request_if.data                 = '0;
  assign  request_if.byte_enable          = '0;
  assign  request_if.payload_status       = TNOC_OKAY;
  assign  request_if.response_last        = '0;
  assign  arid                            = axi_if.arid;

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
  tnoc_axi_id               rid;
  logic                     response_busy;
  tnoc_response_status      packet_status;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      response_busy <= '0;
    end
    else if (
      response_if.payload_valid &&
      response_if.payload_ready &&
      response_if.payload_last
    ) begin
      response_busy <= '0;
    end
    else if (response_if.header_valid) begin
      response_busy <= '1;
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      packet_status <= TNOC_OKAY;
      rid           <= '0;
    end
    else if (response_if.header_valid) begin
      packet_status <= response_if.packet_status;
      rid           <= '{location_id: '0, tag: response_if.tag};
    end
  end

  assign  axi_if.rvalid             = response_if.payload_valid;
  assign  response_if.header_ready  = ~response_busy;
  assign  response_if.payload_ready = axi_if.rready;
  assign  axi_if.rid                = rid;
  assign  axi_if.rdata              = response_if.data;
  assign  axi_if.rresp              = get_rresp(packet_status, response_if.payload_status);
  assign  axi_if.rlast              = response_if.response_last;

  function automatic tnoc_axi_response get_rresp(
    input tnoc_response_status  packet_status,
    input tnoc_response_status  payload_status
  );
    if (payload_status inside {TNOC_SLAVE_ERROR, TNOC_DECODE_ERROR}) begin
      return tnoc_axi_response'(payload_status);
    end
    else if (packet_status inside {TNOC_SLAVE_ERROR, TNOC_DECODE_ERROR}) begin
      return tnoc_axi_response'(packet_status);
    end
    else begin
      return tnoc_axi_response'(payload_status);
    end
  endfunction

  tnoc_packet_unpacker #(CONFIG, 1) u_packet_unpacker (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .flit_in_if     (flit_in_if   ),
    .packet_out_if  (response_if  )
  );
endmodule
