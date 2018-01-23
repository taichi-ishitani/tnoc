module noc_route_selector
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG          = NOC_DEFAULT_CONFIG,
  parameter   int         X               = 0,
  parameter   int         Y               = 0,
  parameter   bit [4:0]   AVAILABLE_PORTS = 5'b11111,
  localparam  int         CHANNELS        = CONFIG.virtual_channels
)(
  input logic                   clk,
  input logic                   rst_n,
  noc_flit_if.target            flit_in_if[CHANNELS],
  noc_flit_if.initiator         flit_out_if[5],
  noc_port_control_if.requester port_control_if[5]
);
  localparam  int SIZE_X  = CONFIG.size_x;
  localparam  int SIZE_Y  = CONFIG.size_y;

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

  function automatic e_route select_route(input noc_flit flit);
    noc_common_header header  = get_common_header(flit);
    noc_location_id   id      = header.destination_id;
    case (1'b1)
      (id.x > X) && AVAILABLE_PORTS[0]: return ROUTE_X_PLUS;
      (id.x < X) && AVAILABLE_PORTS[1]: return ROUTE_X_MINUS;
      (id.y > Y) && AVAILABLE_PORTS[2]: return ROUTE_Y_PLUS;
      (id.y < Y) && AVAILABLE_PORTS[3]: return ROUTE_Y_MINUS;
      default:                          return ROUTE_LOCAL;
    endcase
  endfunction

  function automatic noc_flit set_invalid_destination_flag(input noc_flit flit);
    noc_common_header header  = get_common_header(flit);
    noc_location_id   id      = header.destination_id;
    if (is_header_flit(flit) && ((id.x >= SIZE_X) || (id.y >= SIZE_Y))) begin
      header.invalid_destination  = '1;
      return set_common_header(flit, header);
    end
    else begin
      return flit;
    end
  endfunction

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  noc_flit_if #(CONFIG, 1)  flit_routed_if[5*CHANNELS]();

  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_routing
    logic   start_of_packet;
    logic   end_of_packet;
    e_route route;
    e_route route_next;
    e_route route_temp;

    assign  start_of_packet = (
      flit_in_if[i].valid && is_head_flit(flit_in_if[i].flit)
    ) ? '1 : '0;
    assign  end_of_packet   = (
      flit_in_if[i].valid && flit_in_if[i].ready && is_tail_flit(flit_in_if[i].flit)
    ) ? '1 : '0;

    assign  route       = (start_of_packet) ? route_next : route_temp;
    assign  route_next  = select_route(flit_in_if[i].flit);
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        route_temp  <= ROUTE_NA;
      end
      else if (end_of_packet) begin
        route_temp  <= ROUTE_NA;
      end
      else if (start_of_packet) begin
        route_temp  <= route_next;
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

    noc_flit_if #(CONFIG, 1)  demux_in_if();
    noc_flit_if #(CONFIG, 1)  demux_out_if[5]();

    assign  demux_in_if.valid           = flit_in_if[i].valid;
    assign  flit_in_if[i].ready         = demux_in_if.ready;
    assign  demux_in_if.flit            = set_invalid_destination_flag(flit_in_if[i].flit);
    assign  flit_in_if[i].vc_available  = demux_in_if.vc_available;

    noc_flit_if_demux #(
      .CONFIG   (CONFIG ),
      .CHANNELS (1      ),
      .ENTRIES  (5      )
    ) u_demux (
      .i_select     (route        ),
      .flit_in_if   (demux_in_if  ),
      .flit_out_if  (demux_out_if )
    );

    for (genvar j = 0;j < 5;++j) begin : g_renaming
      noc_flit_if_renamer u_renamer (demux_out_if[j], flit_routed_if[CHANNELS*j+i]);
    end
  end endgenerate

//--------------------------------------------------------------
//  VC Merging
//--------------------------------------------------------------
  generate for (genvar i = 0;i < 5;++i) begin : g_vc_merging
    if (AVAILABLE_PORTS[i]) begin : g
      noc_flit_if #(CONFIG, 1)  flit_vc_if[CHANNELS]();

      for (genvar j = 0;j < CHANNELS;++j) begin : g_renaming
        noc_flit_if_renamer u_renamer (flit_routed_if[CHANNELS*i+j], flit_vc_if[j]);
      end

      noc_vc_merger #(CONFIG) u_vc_merger (
        .clk          (clk                      ),
        .rst_n        (rst_n                    ),
        .i_vc_grant   (port_control_if[i].grant ),
        .flit_in_if   (flit_vc_if               ),
        .flit_out_if  (flit_out_if[i]           )
      );
    end
    else begin : g_dummy
      for (genvar j = 0;j < CHANNELS;++j) begin
        assign  flit_routed_if[CHANNELS*i+j].ready        = '0;
        assign  flit_routed_if[CHANNELS*i+j].vc_available = '0;
      end

      assign  flit_out_if[i].valid  = '0;
      assign  flit_out_if[i].flit   = '0;
    end
  end endgenerate
endmodule
