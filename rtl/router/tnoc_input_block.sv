module tnoc_input_block
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter int         X               = 0,
  parameter int         Y               = 0,
  parameter bit [4:0]   AVAILABLE_PORTS = 5'b11111
)(
  input logic                     clk,
  input logic                     rst_n,
  tnoc_flit_if.target             flit_in_if,
  tnoc_flit_if.initiator          flit_out_if_xp,
  tnoc_flit_if.initiator          flit_out_if_xm,
  tnoc_flit_if.initiator          flit_out_if_yp,
  tnoc_flit_if.initiator          flit_out_if_ym,
  tnoc_flit_if.initiator          flit_out_if_l,
  tnoc_port_control_if.requester  port_control_if_xp,
  tnoc_port_control_if.requester  port_control_if_xm,
  tnoc_port_control_if.requester  port_control_if_yp,
  tnoc_port_control_if.requester  port_control_if_yn,
  tnoc_port_control_if.requester  port_control_if_l
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  tnoc_flit_if #(CONFIG, 1)       flit_fifo_if[CHANNELS]();
  tnoc_flit_if #(CONFIG)          flit_out_if[5]();
  tnoc_port_control_if #(CONFIG)  port_control_if[5]();

  tnoc_flit_if_renamer u_flit_if_renamer_0 (flit_out_if[0], flit_out_if_xp);
  tnoc_flit_if_renamer u_flit_if_renamer_1 (flit_out_if[1], flit_out_if_xm);
  tnoc_flit_if_renamer u_flit_if_renamer_2 (flit_out_if[2], flit_out_if_yp);
  tnoc_flit_if_renamer u_flit_if_renamer_3 (flit_out_if[3], flit_out_if_ym);
  tnoc_flit_if_renamer u_flit_if_renamer_4 (flit_out_if[4], flit_out_if_l );

  tnoc_port_control_if_renamer u_port_control_if_renamer_0 (port_control_if[0], port_control_if_xp);
  tnoc_port_control_if_renamer u_port_control_if_renamer_1 (port_control_if[1], port_control_if_xm);
  tnoc_port_control_if_renamer u_port_control_if_renamer_2 (port_control_if[2], port_control_if_yp);
  tnoc_port_control_if_renamer u_port_control_if_renamer_3 (port_control_if[3], port_control_if_yn);
  tnoc_port_control_if_renamer u_port_control_if_renamer_4 (port_control_if[4], port_control_if_l );

//--------------------------------------------------------------
//  Input FIFO
//--------------------------------------------------------------
  tnoc_input_fifo #(
    .CONFIG (CONFIG )
  ) u_input_fifo (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .i_clear        ('0           ),
    .o_empty        (),
    .o_almost_full  (),
    .o_full         (),
    .flit_in_if     (flit_in_if   ),
    .flit_out_if    (flit_fifo_if )
  );

//--------------------------------------------------------------
//  Route Selector
//--------------------------------------------------------------
  tnoc_route_selector #(
    .CONFIG           (CONFIG           ),
    .X                (X                ),
    .Y                (Y                ),
    .AVAILABLE_PORTS  (AVAILABLE_PORTS  )
  ) u_route_selector (
    .clk              (clk              ),
    .rst_n            (rst_n            ),
    .flit_in_if       (flit_fifo_if     ),
    .flit_out_if      (flit_out_if      ),
    .port_control_if  (port_control_if  )
  );
endmodule
