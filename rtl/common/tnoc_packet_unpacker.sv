module tnoc_packet_unpacker
  `include  "tnoc_default_imports.svh"
#(
  parameter
    tnoc_config     CONFIG      = TNOC_DEFAULT_CONFIG,
    int             CHANNELS    = CONFIG.virtual_channels,
    int             FIFO_DEPTH  = CONFIG.input_fifo_depth,
    tnoc_port_type  PORT_TYPE   = TNOC_LOCAL_PORT
)(
  input logic               clk,
  input logic               rst_n,
  tnoc_flit_if.target       flit_in_if,
  tnoc_packet_if.initiator  packet_out_if
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet_flit_macros.svh"
  `tnoc_define_packet_and_flit(CONFIG)

//--------------------------------------------------------------
//  Flit IF
//--------------------------------------------------------------
  tnoc_flit_if #(CONFIG, 1, PORT_TYPE)  flit_if();

  logic     flit_valid;
  logic     flit_ready;
  tnoc_flit flit;
  logic     header_flit_valid;
  logic     header_flit_ready;
  logic     payload_flit_valid;
  logic     payload_flit_ready;

  if (CHANNELS == 1) begin : g_single_vc
    `tnoc_flit_if_renamer(flit_in_if, flit_if)
  end
  else begin : g_multi_vc
    tnoc_vc_selector #(
      .CONFIG     (CONFIG     ),
      .FIFO_DEPTH (FIFO_DEPTH ),
      .PORT_TYPE  (PORT_TYPE  )
    ) u_vc_selector (
      .clk          (clk        ),
      .rst_n        (rst_n      ),
      .flit_in_if   (flit_in_if ),
      .flit_out_if  (flit_if    )
    );
  end

  assign  flit_valid            = flit_if.valid;
  assign  flit_if.ready         = flit_ready;
  assign  flit                  = flit_if.flit;
  assign  flit_if.vc_available  = '1;
  assign  header_flit_valid     = (is_header_flit(flit) ) ? flit_valid        : '0;
  assign  payload_flit_valid    = (is_payload_flit(flit)) ? flit_valid        : '0;
  assign  flit_ready            = (is_header_flit(flit) ) ? header_flit_ready : payload_flit_ready;

//--------------------------------------------------------------
//  Header
//--------------------------------------------------------------
  localparam  int REQUEST_HEADER_FLITS  = calc_request_header_flits();
  localparam  int RESPONSE_HEADER_FLITS = calc_response_header_flits();
  localparam  int HEADER_FLITS          = calc_header_flits();
  localparam  int HEADER_DATA_WIDTH     = HEADER_FLITS * TNOC_FLIT_DATA_WIDTH;

  logic [HEADER_DATA_WIDTH-1:0] header_data;
  tnoc_common_header            common_header;
  tnoc_request_header           request_header;
  tnoc_response_header          response_header;

  assign  common_header   = header_data;
  assign  request_header  = header_data;
  assign  response_header = header_data;

  assign  packet_out_if.packet_type         = common_header.packet_type;
  assign  packet_out_if.destination_id      = common_header.destination_id;
  assign  packet_out_if.source_id           = common_header.source_id;
  assign  packet_out_if.vc                  = common_header.vc;
  assign  packet_out_if.tag                 = common_header.tag;
  assign  packet_out_if.routing_mode        = common_header.routing_mode;
  assign  packet_out_if.invalid_destination = common_header.invalid_destination;
  assign  packet_out_if.burst_type          = request_header.burst_type;
  assign  packet_out_if.burst_length        = unpack_burst_length(request_header.burst_length);
  assign  packet_out_if.burst_size          = request_header.burst_size;
  assign  packet_out_if.address             = request_header.address;
  assign  packet_out_if.packet_status       = response_header.status;

  if (HEADER_FLITS == 1) begin : g_single_header_flit
    assign  packet_out_if.header_valid  = header_flit_valid;
    assign  header_flit_ready           = packet_out_if.header_ready;
    assign  header_data                 = flit.data;
  end
  else begin : g_multi_header_flits
    localparam  int COUNTER_WIDTH = $clog2(HEADER_FLITS);

    logic [COUNTER_WIDTH-1:0] flit_count;
    tnoc_flit_data            flit_buffer[HEADER_FLITS-1];
    logic                     header_flit_last;

    assign  header_flit_last            = is_last_header_flit(common_header, flit_count);
    assign  packet_out_if.header_valid  = (header_flit_last) ? header_flit_valid          : '0;
    assign  header_flit_ready           = (header_flit_last) ? packet_out_if.header_ready : '1;

    for (genvar i = 0;i < HEADER_FLITS;++i) begin
      if (i < (HEADER_FLITS - 1)) begin
        assign  header_data[i*TNOC_FLIT_DATA_WIDTH+:TNOC_FLIT_DATA_WIDTH] =
          (flit_count == i) ? flit.data : flit_buffer[i];
      end
      else begin
        assign  header_data[i*TNOC_FLIT_DATA_WIDTH+:TNOC_FLIT_DATA_WIDTH] = flit.data;
      end
    end

    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        flit_count  <= 0;
        flit_buffer <= '{default: '0};
      end
      else if (header_flit_valid && header_flit_ready) begin
        if (header_flit_last) begin
          flit_count  <= 0;
          flit_buffer <= '{default: '0};
        end
        else begin
          flit_count              <= flit_count + 1;
          flit_buffer[flit_count] <= flit.data;
        end
      end
    end

    function automatic logic is_last_header_flit(
      tnoc_common_header        common_header,
      logic [COUNTER_WIDTH-1:0] flit_count
    );
      if (is_request_packet_type(common_header.packet_type)) begin
        return (flit_count == (REQUEST_HEADER_FLITS - 1)) ? '1 : '0;
      end
      else begin
        return (flit_count == (RESPONSE_HEADER_FLITS - 1)) ? '1 : '0;
      end
    endfunction
  end

//--------------------------------------------------------------
//  Payload
//--------------------------------------------------------------
  tnoc_payload_type   payload_type;
  tnoc_write_payload  write_payload;
  tnoc_read_payload   read_payload;

  assign  write_payload                 = get_write_payload(flit);
  assign  read_payload                  = get_read_payload(flit);
  assign  packet_out_if.payload_valid   = payload_flit_valid;
  assign  payload_flit_ready            = packet_out_if.payload_ready;
  assign  packet_out_if.payload_type    = payload_type;
  assign  packet_out_if.payload_last    = flit.tail;
  assign  packet_out_if.data            = write_payload.data;
  assign  packet_out_if.byte_enable     = write_payload.byte_enable;
  assign  packet_out_if.payload_status  = read_payload.status;
  assign  packet_out_if.response_last   = read_payload.response_last;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      payload_type  <= TNOC_WRITE_PAYLOAD;
    end
    else if (header_flit_valid) begin
      payload_type  <= (
        is_response_packet_type(common_header.packet_type)
      ) ? TNOC_READ_PAYLOAD : TNOC_WRITE_PAYLOAD;
    end
  end
endmodule
