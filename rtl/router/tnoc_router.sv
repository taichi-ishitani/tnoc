module tnoc_router
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter int         X               = 0,
  parameter int         Y               = 0,
  parameter bit [4:0]   AVAILABLE_PORTS = 5'b11111
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if_x_plus,
  tnoc_flit_if.initiator  flit_out_if_x_plus,
  tnoc_flit_if.target     flit_in_if_x_minus,
  tnoc_flit_if.initiator  flit_out_if_x_minus,
  tnoc_flit_if.target     flit_in_if_y_plus,
  tnoc_flit_if.initiator  flit_out_if_y_plus,
  tnoc_flit_if.target     flit_in_if_y_minus,
  tnoc_flit_if.initiator  flit_out_if_y_minus,
  tnoc_flit_if.target     flit_in_if_local,
  tnoc_flit_if.initiator  flit_out_if_local
);
  tnoc_flit_if #(CONFIG)          flit_in_if[5]();
  tnoc_flit_if #(CONFIG)          flit_out_if[5]();
  tnoc_flit_if #(CONFIG)          flit_if[25]();
  tnoc_port_control_if #(CONFIG)  port_control_if[25]();

  tnoc_flit_if_renamer u_renamer_in_0 (flit_in_if_x_plus , flit_in_if[0]);
  tnoc_flit_if_renamer u_renamer_in_1 (flit_in_if_x_minus, flit_in_if[1]);
  tnoc_flit_if_renamer u_renamer_in_2 (flit_in_if_y_plus , flit_in_if[2]);
  tnoc_flit_if_renamer u_renamer_in_3 (flit_in_if_y_minus, flit_in_if[3]);
  tnoc_flit_if_renamer u_renamer_in_4 (flit_in_if_local  , flit_in_if[4]);

  tnoc_flit_if_renamer u_renamer_out_0 (flit_out_if[0], flit_out_if_x_plus );
  tnoc_flit_if_renamer u_renamer_out_1 (flit_out_if[1], flit_out_if_x_minus);
  tnoc_flit_if_renamer u_renamer_out_2 (flit_out_if[2], flit_out_if_y_plus );
  tnoc_flit_if_renamer u_renamer_out_3 (flit_out_if[3], flit_out_if_y_minus);
  tnoc_flit_if_renamer u_renamer_out_4 (flit_out_if[4], flit_out_if_local  );

  generate for (genvar i = 0;i < 5;++i) begin : g_input
    if (AVAILABLE_PORTS[i]) begin : g
      tnoc_input_block #(
        .CONFIG           (CONFIG           ),
        .X                (X                ),
        .Y                (Y                ),
        .AVAILABLE_PORTS  (AVAILABLE_PORTS  )
      ) u_input_block (
        .clk                (clk                    ),
        .rst_n              (rst_n                  ),
        .flit_in_if         (flit_in_if[i]          ),
        .flit_out_if_xp     (flit_if[5*0+i]         ),
        .flit_out_if_xm     (flit_if[5*1+i]         ),
        .flit_out_if_yp     (flit_if[5*2+i]         ),
        .flit_out_if_ym     (flit_if[5*3+i]         ),
        .flit_out_if_l      (flit_if[5*4+i]         ),
        .port_control_if_xp (port_control_if[5*0+i] ),
        .port_control_if_xm (port_control_if[5*1+i] ),
        .port_control_if_yp (port_control_if[5*2+i] ),
        .port_control_if_yn (port_control_if[5*3+i] ),
        .port_control_if_l  (port_control_if[5*4+i] )
      );
    end
    else begin : g_dummy
      tnoc_input_block_dummy #(
        .CONFIG (CONFIG )
      ) u_dummy (
        .flit_in_if         (flit_in_if[i]          ),
        .flit_out_if_xp     (flit_if[5*0+i]         ),
        .flit_out_if_xm     (flit_if[5*1+i]         ),
        .flit_out_if_yp     (flit_if[5*2+i]         ),
        .flit_out_if_ym     (flit_if[5*3+i]         ),
        .flit_out_if_l      (flit_if[5*4+i]         ),
        .port_control_if_xp (port_control_if[5*0+i] ),
        .port_control_if_xm (port_control_if[5*1+i] ),
        .port_control_if_yp (port_control_if[5*2+i] ),
        .port_control_if_yn (port_control_if[5*3+i] ),
        .port_control_if_l  (port_control_if[5*4+i] )
      );
    end
  end endgenerate

  generate for (genvar i = 0;i < 5;++i) begin : g_output
    if (AVAILABLE_PORTS[i]) begin : g
      tnoc_output_block #(
        .CONFIG (CONFIG )
      ) u_output_block (
        .clk                (clk                    ),
        .rst_n              (rst_n                  ),
        .flit_in_if_xp      (flit_if[5*i+0]         ),
        .flit_in_if_xm      (flit_if[5*i+1]         ),
        .flit_in_if_yp      (flit_if[5*i+2]         ),
        .flit_in_if_ym      (flit_if[5*i+3]         ),
        .flit_in_if_l       (flit_if[5*i+4]         ),
        .flit_out_if        (flit_out_if[i]         ),
        .port_control_if_xp (port_control_if[5*i+0] ),
        .port_control_if_xm (port_control_if[5*i+1] ),
        .port_control_if_yp (port_control_if[5*i+2] ),
        .port_control_if_ym (port_control_if[5*i+3] ),
        .port_control_if_l  (port_control_if[5*i+4] )
      );
    end
    else begin : g_dummy
      tnoc_output_block_dummy #(
        .CONFIG (CONFIG )
      ) u_block_dummy (
        .flit_in_if_xp      (flit_if[5*i+0]         ),
        .flit_in_if_xm      (flit_if[5*i+1]         ),
        .flit_in_if_yp      (flit_if[5*i+2]         ),
        .flit_in_if_ym      (flit_if[5*i+3]         ),
        .flit_in_if_l       (flit_if[5*i+4]         ),
        .flit_out_if        (flit_out_if[i]         ),
        .port_control_if_xp (port_control_if[5*i+0] ),
        .port_control_if_xm (port_control_if[5*i+1] ),
        .port_control_if_yp (port_control_if[5*i+2] ),
        .port_control_if_ym (port_control_if[5*i+3] ),
        .port_control_if_l  (port_control_if[5*i+4] )
      );
    end
  end endgenerate
endmodule
