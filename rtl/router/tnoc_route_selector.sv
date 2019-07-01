module tnoc_route_selector
  `include  "tnoc_default_imports.svh"
#(
  parameter
    tnoc_config CONFIG          = TNOC_DEFAULT_CONFIG,
    bit [4:0]   AVAILABLE_PORTS = 5'b11111,
  localparam
    int         CHANNELS        = CONFIG.virtual_channels,
    int         ID_X_WIDTH      = CONFIG.id_x_width,
    int         ID_Y_WIDTH      = CONFIG.id_y_width
)(
  input logic                     clk,
  input logic                     rst_n,
  input logic [ID_X_WIDTH-1:0]    i_id_x,
  input logic [ID_Y_WIDTH-1:0]    i_id_y,
  tnoc_flit_if.target             flit_in_if[CHANNELS],
  tnoc_flit_if.initiator          flit_out_if[5],
  tnoc_port_control_if.requester  port_control_if[5]
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet_flit_macros.svh"
  `tnoc_define_packet_and_flit(CONFIG)

  typedef enum logic [4:0] {
    ROUTE_X_PLUS  = 5'b00001,
    ROUTE_X_MINUS = 5'b00010,
    ROUTE_Y_PLUS  = 5'b00100,
    ROUTE_Y_MINUS = 5'b01000,
    ROUTE_LOCAL   = 5'b10000,
    ROUTE_NA      = 5'b00000
  } e_route;

  function automatic e_route select_route(
    input tnoc_flit               flit,
    input logic [ID_X_WIDTH-1:0]  id_x,
    input logic [ID_Y_WIDTH-1:0]  id_y
  );
    tnoc_common_header  header  = get_common_header(flit);
    tnoc_location_id    id      = header.destination_id;
    logic [3:0]         result;

    result[0] = ((id.x > id_x) && AVAILABLE_PORTS[0]) ? '1 : '0;
    result[1] = ((id.x < id_x) && AVAILABLE_PORTS[1]) ? '1 : '0;
    result[2] = ((id.y > id_y) && AVAILABLE_PORTS[2]) ? '1 : '0;
    result[3] = ((id.y < id_y) && AVAILABLE_PORTS[3]) ? '1 : '0;

    case (1'b1)
      result[0]:  return ROUTE_X_PLUS;
      result[1]:  return ROUTE_X_MINUS;
      result[2]:  return ROUTE_Y_PLUS;
      result[3]:  return ROUTE_Y_MINUS;
      default:    return ROUTE_LOCAL;
    endcase
  endfunction

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  `tnoc_internal_flit_if(1) flit_routed_if[5*CHANNELS]();

  for (genvar i = 0;i < CHANNELS;++i) begin : g_routing
    logic   start_of_packet;
    logic   end_of_packet;
    e_route route;
    e_route route_next;
    e_route route_latched;

    assign  start_of_packet = (flit_in_if[i].valid           && is_head_flit(flit_in_if[i].flit)) ? '1 : '0;
    assign  end_of_packet   = (`tnoc_flit_ack(flit_in_if[i]) && is_tail_flit(flit_in_if[i].flit)) ? '1 : '0;

    assign  route       = (start_of_packet) ? route_next : route_latched;
    assign  route_next  = select_route(flit_in_if[i].flit, i_id_x, i_id_y);
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        route_latched <= ROUTE_NA;
      end
      else if (end_of_packet) begin
        route_latched <= ROUTE_NA;
      end
      else if (start_of_packet) begin
        route_latched <= route_next;
      end
    end

    for (genvar j = 0;j < 5;++j) begin
      if (AVAILABLE_PORTS[j]) begin
        assign  port_control_if[j].request[i]         = (route[j]) ? flit_in_if[i].valid : '0;
        assign  port_control_if[j].free[i]            = (route[j]) ? flit_in_if[i].ready : '0;
        assign  port_control_if[j].start_of_packet[i] = (route[j]) ? start_of_packet     : '0;
        assign  port_control_if[j].end_of_packet[i]   = (route[j]) ? end_of_packet       : '0;
      end
      else begin
        assign  port_control_if[j].request[i]         = '0;
        assign  port_control_if[j].free[i]            = '0;
        assign  port_control_if[j].start_of_packet[i] = '0;
        assign  port_control_if[j].end_of_packet[i]   = '0;
      end
    end

    tnoc_flit_if_demux #(
      .CONFIG   (CONFIG ),
      .CHANNELS (1      ),
      .ENTRIES  (5      )
    ) u_demux (
      .i_select     (route                                    ),
      .flit_in_if   (flit_in_if[i]                            ),
      .flit_out_if  (`tnoc_array_slicer(flit_routed_if, i, 5) )
    );
  end

//--------------------------------------------------------------
//  VC Merging
//--------------------------------------------------------------
  `tnoc_internal_flit_if(1) flit_vc_if[5*CHANNELS]();

  for (genvar i = 0;i < 5;++i) begin : g_vc_merging
    for (genvar j = 0;j < CHANNELS;++j) begin
      `tnoc_flit_if_renamer(flit_routed_if[5*j+i], flit_vc_if[CHANNELS*i+j])
    end

    if (AVAILABLE_PORTS[i]) begin : g
      tnoc_vc_merger #(CONFIG) u_vc_merger (
        .clk          (clk                                          ),
        .rst_n        (rst_n                                        ),
        .i_vc_grant   (port_control_if[i].grant                     ),
        .flit_in_if   (`tnoc_array_slicer(flit_vc_if, i, CHANNELS)  ),
        .flit_out_if  (flit_out_if[i]                               )
      );
    end
    else begin : g_dummy
      tnoc_flit_if_dummy_initiator #(
        .CONFIG     (CONFIG             ),
        .PORT_TYPE  (TNOC_INTERNAL_PORT )
      ) u_dummy_initiator (
        flit_out_if[i]
      );
      for (genvar j = 0;j < CHANNELS;++j) begin : g
        tnoc_flit_if_dummy_target #(
          .CONFIG     (CONFIG             ),
          .CHANNELS   (1                  ),
          .PORT_TYPE  (TNOC_INTERNAL_PORT )
        ) u_dummy_target(
          flit_vc_if[CHANNELS*i+j]
        );
      end
    end
  end
endmodule
