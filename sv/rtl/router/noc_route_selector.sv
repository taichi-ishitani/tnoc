module noc_route_selector
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  parameter int         X         = 0,
  parameter int         Y         = 0
)(
  input logic               clk,
  input logic               rst_n,
  noc_flit_bus_if.target    flit_in_if,
  noc_flit_bus_if.initiator flit_out_if_x_plus,
  noc_flit_bus_if.initiator flit_out_if_x_minus,
  noc_flit_bus_if.initiator flit_out_if_y_plus,
  noc_flit_bus_if.initiator flit_out_if_y_minus,
  noc_flit_bus_if.initiator flit_out_if_local
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

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

  genvar  g_i;
  genvar  g_j;

  function automatic e_route select_route(input noc_location_id destination_id);
    case (1'b1)
      (destination_id.x > X): return ROUTE_X_PLUS;
      (destination_id.x < X): return ROUTE_X_MINUS;
      (destination_id.y > Y): return ROUTE_Y_PLUS;
      (destination_id.y < Y): return ROUTE_Y_MINUS;
      default:                return ROUTE_LOCAL;
    endcase
  endfunction

  noc_flit_bus_if #(CONFIG) flit_out_if[5]();

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_channel
    noc_flit_channel_if #(CONFIG) flit_in_channel_if();
    noc_flit_channel_if #(CONFIG) flit_channel_demux_if[5]();
    logic                         start_of_packet;
    logic                         end_of_packet;
    logic                         busy;
    noc_common_header             header;
    logic [4:0]                   output_route_temp[2];
    e_route                       output_route;

    assign  flit_in_channel_if.valid  = flit_in_if.valid[g_i];
    assign  flit_in_if.ready[g_i]     = flit_in_channel_if.ready;
    assign  flit_in_channel_if.flit   = flit_in_if.flit[g_i];

    //  Channel Status
    assign  start_of_packet = (
      flit_in_channel_if.valid && (!busy) && is_header_flit(flit_in_channel_if.flit)
    ) ? '1 : '0;
    assign  end_of_packet   = (
      flit_in_channel_if.valid && flit_in_channel_if.ready && is_tail_flit(flit_in_channel_if.flit)
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

    //  Route Selection
    assign  header                = get_common_header(flit_in_channel_if.flit);
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

    noc_flit_channel_demux #(
      .CONFIG     (CONFIG ),
      .CHANNELS   (5      ),
      .FIFO_DEPTH (2      )
    ) u_flit_channe_demux (
      .clk          (clk                    ),
      .rst_n        (rst_n                  ),
      .i_select     (output_route           ),
      .flit_in_if   (flit_in_channel_if     ),
      .flit_out_if  (flit_channel_demux_if  )
    );

    for (g_j = 0;g_j < 5;++g_j) begin
      assign  flit_out_if[g_j].valid[g_i]       = flit_channel_demux_if[g_j].valid;
      assign  flit_channel_demux_if[g_j].ready  = flit_out_if[g_j].ready[g_i];
      assign  flit_out_if[g_j].flit[g_i]        = flit_channel_demux_if[g_j].flit;
    end
  end endgenerate

//--------------------------------------------------------------
//  Renaming
//--------------------------------------------------------------
  noc_flit_bus_renamer #(CONFIG) u_renamer_x_plus (
    flit_out_if[0], flit_out_if_x_plus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_x_minus (
    flit_out_if[1], flit_out_if_x_minus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_plus (
    flit_out_if[2], flit_out_if_y_plus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_y_minus (
    flit_out_if[3], flit_out_if_y_minus
  );
  noc_flit_bus_renamer #(CONFIG) u_renamer_local (
    flit_out_if[4], flit_out_if_local
  );
endmodule
