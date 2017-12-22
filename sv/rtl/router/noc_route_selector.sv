module noc_route_selector
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         X         = 0,
  parameter int         Y         = 0
)(
  input logic                   clk,
  input logic                   rst_n,
  noc_flit_channel_if.target    flit_in_if,
  noc_flit_channel_if.initiator flit_out_if[5]
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"
  `include  "noc_flit_utils.svh"

  typedef enum logic [4:0] {
    ROUTE_X_PLUS  = 5'b00001,
    ROUTE_X_MINUS = 5'b00010,
    ROUTE_Y_PLUS  = 5'b00100,
    ROUTE_Y_MINUS = 5'b01000,
    ROUTE_LOCAL   = 5'b10000,
    ROUTE_NA      = 5'b00000
  } e_route;

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  //  Channel State
  logic             start_of_packet;
  logic             end_of_packet;
  logic             busy;

  assign  start_of_packet = (
    flit_in_if.valid && (!busy) && is_header_flit(flit_in_if.flit)
  ) ? '1 : '0;
  assign  end_of_packet = (
    flit_in_if.valid && flit_in_if.ready && is_tail_flit(flit_in_if.flit)
  ) ? '1 : '0;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy  <= '0;
    end
    else if (end_of_packet) begin
      busy  <= '0;
    end
    else if (start_of_packet) begin
      busy  <= '1;
    end
  end

  //  Selecting Route
  noc_common_header header;
  e_route           output_route;
  logic [4:0]       output_route_temp[2];

  assign  header                = get_common_header(flit_in_if.flit);
  assign  output_route_temp[0]  = select_route(header.destination_id);
  assign  output_route          = e_route'(output_route_temp[1]);

  noc_value_keeper #(5, ROUTE_NA) u_output_route_keeper (
    .clk      (clk                  ),
    .rst_n    (rst_n                ),
    .i_clear  (end_of_packet        ),
    .i_valid  (start_of_packet      ),
    .i_value  (output_route_temp[0] ),
    .o_value  (output_route_temp[1] )
  );

  function automatic e_route select_route(input noc_location_id destination_id);
    case (1'b1)
      (destination_id.x > X): return ROUTE_X_PLUS;
      (destination_id.x < X): return ROUTE_X_MINUS;
      (destination_id.y > Y): return ROUTE_Y_PLUS;
      (destination_id.y < Y): return ROUTE_Y_MINUS;
      default:                return ROUTE_LOCAL;
    endcase
  endfunction

  //  Output DEMUX
  noc_flit_channel_demux #(
    .CONFIG     (CONFIG ),
    .CHANNELS   (5      ),
    .FIFO_DEPTH (2      )
  ) u_flit_channe_demux (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .i_select     (output_route ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
