module tnoc_input_block
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter int             X               = 0,
  parameter int             Y               = 0,
  parameter tnoc_port_type  PORT_TYPE       = TNOC_LOCAL_PORT,
  parameter bit [4:0]       AVAILABLE_PORTS = 5'b11111
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
  tnoc_port_control_if.requester  port_control_if_ym,
  tnoc_port_control_if.requester  port_control_if_l
);
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS  = CONFIG.virtual_channels;

  `tnoc_internal_flit_if(1       )  flit_fifo_if[CHANNELS]();
  `tnoc_internal_flit_if(1       )  flit_error_checker_if[CHANNELS]();
  `tnoc_internal_flit_if(CHANNELS)  flit_out_if[5]();
  tnoc_port_control_if #(CONFIG)    port_control_if[5]();

  `tnoc_flit_if_renamer(flit_out_if[0], flit_out_if_xp);
  `tnoc_flit_if_renamer(flit_out_if[1], flit_out_if_xm);
  `tnoc_flit_if_renamer(flit_out_if[2], flit_out_if_yp);
  `tnoc_flit_if_renamer(flit_out_if[3], flit_out_if_ym);
  `tnoc_flit_if_renamer(flit_out_if[4], flit_out_if_l );

  `tnoc_port_control_if_renamer(port_control_if[0], port_control_if_xp);
  `tnoc_port_control_if_renamer(port_control_if[1], port_control_if_xm);
  `tnoc_port_control_if_renamer(port_control_if[2], port_control_if_yp);
  `tnoc_port_control_if_renamer(port_control_if[3], port_control_if_ym);
  `tnoc_port_control_if_renamer(port_control_if[4], port_control_if_l );

//--------------------------------------------------------------
//  Input FIFO
//--------------------------------------------------------------
  tnoc_input_fifo #(
    .CONFIG     (CONFIG     ),
    .PORT_TYPE  (PORT_TYPE  )
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
//  Error Checker
//--------------------------------------------------------------
  if (is_local_port(PORT_TYPE)) begin : g_error_checker
    for (genvar i = 0;i < CHANNELS;++i) begin : g
      tnoc_error_checker #(CONFIG) u_error_checker (
        .clk          (clk                      ),
        .rst_n        (rst_n                    ),
        .flit_in_if   (flit_fifo_if[i]          ),
        .flit_out_if  (flit_error_checker_if[i] )
      );
    end
  end
  else begin
    `tnoc_flit_array_if_renamer(flit_fifo_if, flit_error_checker_if, CHANNELS)
  end

//--------------------------------------------------------------
//  Route Selector
//--------------------------------------------------------------
  tnoc_route_selector #(
    .CONFIG           (CONFIG           ),
    .X                (X                ),
    .Y                (Y                ),
    .AVAILABLE_PORTS  (AVAILABLE_PORTS  )
  ) u_route_selector (
    .clk              (clk                    ),
    .rst_n            (rst_n                  ),
    .flit_in_if       (flit_error_checker_if  ),
    .flit_out_if      (flit_out_if            ),
    .port_control_if  (port_control_if        )
  );
endmodule
