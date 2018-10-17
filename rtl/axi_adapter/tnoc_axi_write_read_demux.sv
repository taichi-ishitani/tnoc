module tnoc_axi_write_read_demux
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config       CONFIG      = TNOC_DEFAULT_CONFIG,
  parameter tnoc_packet_type  WRITE_TYPE  = TNOC_NON_POSTED_WRITE,
  parameter tnoc_packet_type  READ_TYPE   = TNOC_READ
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  write_flit_if,
  tnoc_flit_if.initiator  read_flit_if
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"
  `include  "tnoc_flit_utils.svh"

  localparam  int CHANNELS  = CONFIG.virtual_channels;

  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  write_read_if[2*CHANNELS]();
  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  flit_out[2]();

//--------------------------------------------------------------
//  Routing
//--------------------------------------------------------------
  for (genvar i = 0;i < CHANNELS;++i) begin : g_router
    logic       start_of_packet;
    logic [1:0] route;
    logic [1:0] route_latched;

    assign  start_of_packet = (flit_in_if.valid[i] && is_head_flit(flit_in_if.flit[i])) ? '1 : '0;
    assign  route           = (start_of_packet) ? select_route(flit_in_if.flit[i]) : route_latched;
    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        route_latched <= '0;
      end
      else if (start_of_packet) begin
        route_latched <= route;
      end
    end

    assign  write_read_if[0*CHANNELS+i].valid   = (route[0]) ? flit_in_if.valid[i] : '0;
    assign  write_read_if[0*CHANNELS+i].flit[0] = (route[0]) ? flit_in_if.flit[i]  : '0;
    assign  write_read_if[1*CHANNELS+i].valid   = (route[0]) ? flit_in_if.valid[i] : '0;
    assign  write_read_if[1*CHANNELS+i].flit[0] = (route[0]) ? flit_in_if.flit[i]  : '0;

    assign  flit_in_if.ready[i]         = (route[0]) ? write_read_if[0*CHANNELS+i].ready
                                        : (route[1]) ? write_read_if[1*CHANNELS+i].ready        : '1;
    assign  flit_in_if.vc_available[i]  = (route[0]) ? write_read_if[0*CHANNELS+i].vc_available
                                        : (route[1]) ? write_read_if[1*CHANNELS+i].vc_available : '1;
  end

  function automatic logic [1:0] select_route(input tnoc_flit flit);
    tnoc_common_header  header  = get_common_header(flit);
    return {
      ((header.packet_type == READ_TYPE ) ? 1'b1 : 1'b0),
      ((header.packet_type == WRITE_TYPE) ? 1'b1 : 1'b0)
    };
  endfunction

//--------------------------------------------------------------
//  Arbitration
//--------------------------------------------------------------
  for (genvar i = 0;i < 2;++i) begin : g_arbiter
    tnoc_flit_if_arbiter #(
      .CONFIG     (CONFIG           ),
      .ENTRIES    (CHANNELS         ),
      .CHANNELS   (1                ),
      .PORT_TYPE  (TNOC_LOCAL_PORT  )
    ) u_arbiter (
      .clk          (clk                                            ),
      .rst_n        (rst_n                                          ),
      .flit_in_if   (`tnoc_array_slicer(write_read_if, i, CHANNELS) ),
      .flit_out_if  (flit_out[i]                                    )
    );
  end

  `tnoc_flit_if_renamer(flit_out[0], write_flit_if)
  `tnoc_flit_if_renamer(flit_out[1], read_flit_if)
endmodule
