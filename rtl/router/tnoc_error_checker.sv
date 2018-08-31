module tnoc_error_checker
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet.svh"
  `include  "tnoc_packet_utils.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_flit_utils.svh"

  tnoc_flit           flit;
  tnoc_common_header  common_header;

  assign  flit          = flit_in_if.flit[0];
  assign  common_header = get_common_header(flit);

//--------------------------------------------------------------
//  Error Checking
//--------------------------------------------------------------
  localparam  int SIZE_X  = CONFIG.size_x;
  localparam  int SIZE_Y  = CONFIG.size_y;

  logic invalid_destination;

  assign  invalid_destination = check_invalid_destination(common_header);
  function automatic logic check_invalid_destination(
    input tnoc_common_header  header
  );
    if (
      header.invalid_destination          ||
      (header.destination_id.x >= SIZE_X) ||
      (header.destination_id.y >= SIZE_Y)
    ) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  typedef enum logic [1:0] {
    NORMAL_ROUTE  = 2'b01,
    ERROR_ROUTE   = 2'b10
  } e_route;

  e_route     route;
  e_route     route_next;
  e_route     route_latched;
  logic       start_of_packet;
  logic [1:0] error_route_busy;

  assign  start_of_packet = (
    flit_in_if.valid && is_head_flit(flit) && (error_route_busy == '0)
  ) ? '1 : '0;
  assign  route           = (start_of_packet) ? route_next : route_latched;
  assign  route_next      = (!invalid_destination) ? NORMAL_ROUTE : ERROR_ROUTE;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      route_latched <= NORMAL_ROUTE;
    end
    else if (start_of_packet) begin
      route_latched <= route_next;
    end
  end

  `tnoc_internal_flit_if(1) flit_demux_out_if[2]();
  `tnoc_internal_flit_if(1) flit_mux_in_if[2]();
  `tnoc_internal_flit_if(1) flit_mux_out_if();

  tnoc_flit_if_demux #(
    .CONFIG   (CONFIG ),
    .CHANNELS (1      ),
    .ENTRIES  (2      )
  ) u_flit_demux (
    route, flit_in_if, flit_demux_out_if
  );
  tnoc_flit_if_mux #(
    .CONFIG     (CONFIG             ),
    .CHANNELS   (1                  ),
    .ENTRIES    (2                  ),
    .PORT_TYPE  (TNOC_INTERNAL_PORT )
  ) u_flit_mux (
    route, flit_mux_in_if, flit_mux_out_if
  );
  tnoc_flit_if_slicer #(
    .CONFIG     (CONFIG             ),
    .CHANNELS   (1                  ),
    .PORT_TYPE  (TNOC_INTERNAL_PORT )
  ) u_slicer (
    .clk            (clk              ),
    .rst_n          (rst_n            ),
    .flit_in_if     (flit_mux_out_if  ),
    .flit_out_if    (flit_out_if      )
  );

//--------------------------------------------------------------
//  Normal Route
//--------------------------------------------------------------
  `tnoc_flit_if_renamer(flit_demux_out_if[0], flit_mux_in_if[0])

//--------------------------------------------------------------
//  Error Route
//--------------------------------------------------------------
  logic start_of_error_request;
  logic end_of_error_request;

  assign  start_of_error_request  = (
    start_of_packet && invalid_destination
  ) ? '1 : '0;
  assign  end_of_error_request    = (
    flit_demux_out_if[1].valid && flit_demux_out_if[1].ready && is_tail_flit(flit_demux_out_if[1].flit[0])
  ) ? '1 : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      error_route_busy[0] <= '0;
    end
    else if (end_of_error_request) begin
      error_route_busy[0] <= '0;
    end
    else if (start_of_error_request) begin
      error_route_busy[0] <= '1;
    end
  end

  logic start_of_error_response;
  logic end_of_error_response;

  assign  start_of_error_response = (
    start_of_packet && invalid_destination && is_non_posted_request_packet_type(common_header.packet_type)
  ) ? '1 : '0;
  assign  end_of_error_response   = (
    flit_mux_in_if[1].valid && flit_mux_in_if[1].ready && is_tail_flit(flit_mux_in_if[1].flit[0])
  ) ? '1 : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      error_route_busy[1] <= '0;
    end
    else if (end_of_error_response) begin
      error_route_busy[1] <= '0;
    end
    else if (start_of_error_response) begin
      error_route_busy[1] <= '1;
    end
  end

  tnoc_packet_if #(CONFIG)    error_request_if();
  tnoc_packet_if #(CONFIG)    error_response_if();
  logic                       last_payload_valid;
  logic                       last_error_payload_ready;
  logic [1:0]                 error_response_busy;
  tnoc_common_header          error_request_header;
  tnoc_unpacked_burst_length  payload_count;

  assign  error_request_if.header_ready   =
    (!error_route_busy[1]  ) ? error_route_busy[0]      :
    (error_response_busy[0]) ? last_error_payload_ready :
    (error_response_busy[1]) ? error_route_busy[0]      : '0;
  assign  error_request_if.payload_ready  =
    (error_response_busy[1] && last_payload_valid) ? error_response_if.header_ready : error_route_busy[0];
  assign  last_payload_valid              =
    error_request_if.payload_valid & error_request_if.payload_last;
  tnoc_packet_unpacker #(CONFIG, 1) u_packet_unpacker (
    .clk            (clk                  ),
    .rst_n          (rst_n                ),
    .flit_in_if     (flit_demux_out_if[1] ),
    .packet_out_if  (error_request_if     )
  );

  assign  error_response_if.header_valid        =
    (error_response_busy[0]) ? error_request_if.header_valid :
    (error_response_busy[1]) ? last_payload_valid            : '0;
  assign  error_response_if.packet_type         =
    (error_response_busy[0]) ? TNOC_RESPONSE_WITH_DATA :
    (error_response_busy[1]) ? TNOC_RESPONSE           : TNOC_INVALID_PACKET;
  assign  error_response_if.destination_id      = error_request_header.source_id;
  assign  error_response_if.source_id           = error_request_header.destination_id;
  assign  error_response_if.vc                  = error_request_header.vc;
  assign  error_response_if.tag                 = error_request_header.tag;
  assign  error_response_if.routing_mode        = error_request_header.routing_mode;
  assign  error_response_if.invalid_destination = '0;
  assign  error_response_if.burst_type          = TNOC_INCREMENTING_BURST;
  assign  error_response_if.burst_length        = 0;
  assign  error_response_if.burst_size          = 0;
  assign  error_response_if.address             = '0;
  assign  error_response_if.status              = TNOC_DECODE_ERROR;
  assign  error_response_if.payload_valid       = (payload_count != 0) ? '1 : '0;
  assign  error_response_if.payload_last        = (payload_count == 1) ? '1 : '0;
  assign  error_response_if.data                = CONFIG.error_data[CONFIG.data_width-1:0];
  assign  error_response_if.byte_enable         = '0;
  assign  last_error_payload_ready              =
    error_response_if.payload_last & error_response_if.payload_ready;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      error_response_busy   <= '0;
      error_request_header  <= '0;
    end
    else if (end_of_error_response) begin
      error_response_busy   <= '0;
      error_request_header  <= '0;
    end
    else if (
      error_route_busy[1] && error_request_if.header_valid && (error_response_busy == '0)
    ) begin
      error_response_busy   <= {
        ((is_with_payload_packet_type(error_request_if.packet_type)) ? 1'b1 : 1'b0),
        ((  is_no_payload_packet_type(error_request_if.packet_type)) ? 1'b1 : 1'b0)
      };
      error_request_header  <= '{
        packet_type:          error_request_if.packet_type,
        destination_id:       error_request_if.destination_id,
        source_id:            error_request_if.source_id,
        vc:                   error_request_if.vc,
        tag:                  error_request_if.tag,
        routing_mode:         error_request_if.routing_mode,
        invalid_destination:  error_request_if.invalid_destination
      };
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      payload_count <= 0;
    end
    else if (
      error_route_busy[1] && error_request_if.header_valid && (error_response_busy == '0)
    ) begin
      payload_count <= (
        is_no_payload_packet_type(error_request_if.packet_type)
      ) ? error_request_if.burst_length : 0;
    end
    else if (
      error_response_if.payload_valid && error_response_if.payload_ready
    ) begin
      payload_count <= payload_count - 1;
    end
  end

  tnoc_packet_packer #(
    .CONFIG     (CONFIG             ),
    .CHANNELS   (1                  ),
    .PORT_TYPE  (TNOC_INTERNAL_PORT )
  ) u_packet_packer (
    .clk          (clk                ),
    .rst_n        (rst_n              ),
    .packet_in_if (error_response_if  ),
    .flit_out_if  (flit_mux_in_if[1]  )
  );
endmodule
