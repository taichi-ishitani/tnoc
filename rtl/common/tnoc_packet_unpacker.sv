module tnoc_packet_unpacker
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG      = TNOC_DEFAULT_CONFIG,
  parameter int             CHANNELS    = CONFIG.virtual_channels,
  parameter int             FIFO_DEPTH  = CONFIG.input_fifo_depth,
  parameter tnoc_port_type  PORT_TYPE   = TNOC_LOCAL_PORT
)(
  input logic               clk,
  input logic               rst_n,
  tnoc_flit_if.target       flit_in_if,
  tnoc_packet_if.initiator  packet_out_if
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_packet_utils.svh"
  `include  "tnoc_flit_utils.svh"

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
  assign  flit                  = flit_if.flit[0];
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
  localparam  int HEADER_DATA_WIDTH     = HEADER_FLITS * FLIT_DATA_WIDTH;

  logic [HEADER_DATA_WIDTH-1:0] header_data;
  tnoc_common_header_fields     common_header_fields;
  tnoc_request_header_fields    request_header_fields;
  tnoc_response_header_fields   response_header_fields;

  assign  common_header_fields              = tnoc_common_header_fields'(header_data[COMMON_HEADER_WIDTH-1:0]);
  assign  packet_out_if.packet_type         = common_header_fields.packet_type;
  assign  packet_out_if.destination_id      = common_header_fields.destination_id;
  assign  packet_out_if.source_id           = common_header_fields.source_id;
  assign  packet_out_if.vc                  = common_header_fields.vc;
  assign  packet_out_if.tag                 = common_header_fields.tag;
  assign  packet_out_if.routing_mode        = common_header_fields.routing_mode;
  assign  packet_out_if.invalid_destination = common_header_fields.invalid_destination;
  assign  request_header_fields             = tnoc_request_header_fields'(header_data[REQUEST_HEADER_WIDTH-1:COMMON_HEADER_WIDTH]);
  assign  packet_out_if.burst_type          = request_header_fields.burst_type;
  assign  packet_out_if.burst_length        = request_header_fields.burst_length;
  assign  packet_out_if.burst_size          = request_header_fields.burst_size;
  assign  packet_out_if.address             = request_header_fields.address;
  assign  response_header_fields            = tnoc_response_header_fields'(header_data[RESPONSE_HEADER_WIDTH-1:COMMON_HEADER_WIDTH]);
  assign  packet_out_if.status              = response_header_fields.status;

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

    assign  header_flit_last            = (flit_count == get_last_count(common_header_fields)) ? '1 : '0;
    assign  packet_out_if.header_valid  = (header_flit_last) ? header_flit_valid          : '0;
    assign  header_flit_ready           = (header_flit_last) ? packet_out_if.header_ready : '1;

    for (genvar i = 0;i < HEADER_FLITS;++i) begin
      if (i < (HEADER_FLITS - 1)) begin
        assign  header_data[i*FLIT_DATA_WIDTH+:FLIT_DATA_WIDTH] =
          (flit_count == i) ? flit.data : flit_buffer[i];
      end
      else begin
        assign  header_data[i*FLIT_DATA_WIDTH+:FLIT_DATA_WIDTH] = flit.data;
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

    function automatic logic [COUNTER_WIDTH-1:0] get_last_count(
      input tnoc_common_header_fields common_header_fields
    );
      if (is_request_packet_type(common_header_fields.packet_type)) begin
        return REQUEST_HEADER_FLITS - 1;
      end
      else begin
        return RESPONSE_HEADER_FLITS - 1;
      end
    endfunction
  end

//--------------------------------------------------------------
//  Payload
//--------------------------------------------------------------
  tnoc_payload  payload;

  assign  payload                     = tnoc_payload'(flit.data[PAYLOD_WIDTH-1:0]);
  assign  packet_out_if.payload_valid = payload_flit_valid;
  assign  payload_flit_ready          = packet_out_if.payload_ready;
  assign  packet_out_if.payload_last  = flit.tail;
  assign  packet_out_if.data          = payload.data;
  assign  packet_out_if.byte_enable   = payload.byte_enable;
endmodule
