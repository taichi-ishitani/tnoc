module tnoc_output_block
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)(
  input logic                     clk,
  input logic                     rst_n,
  tnoc_flit_if.target             flit_in_if_xp,
  tnoc_flit_if.target             flit_in_if_xm,
  tnoc_flit_if.target             flit_in_if_yp,
  tnoc_flit_if.target             flit_in_if_ym,
  tnoc_flit_if.target             flit_in_if_l,
  tnoc_flit_if.initiator          flit_out_if,
  tnoc_port_control_if.arbitrator port_control_if_xp,
  tnoc_port_control_if.arbitrator port_control_if_xm,
  tnoc_port_control_if.arbitrator port_control_if_yp,
  tnoc_port_control_if.arbitrator port_control_if_ym,
  tnoc_port_control_if.arbitrator port_control_if_l
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  tnoc_flit_if #(CONFIG)          flit_in_if[5]();
  tnoc_port_control_if #(CONFIG)  port_control_if[5]();
  logic [4:0]                     output_grant;
  logic                           output_free;

  tnoc_flit_if_renamer u_flit_if_renamer_0 (flit_in_if_xp, flit_in_if[0]);
  tnoc_flit_if_renamer u_flit_if_renamer_1 (flit_in_if_xm, flit_in_if[1]);
  tnoc_flit_if_renamer u_flit_if_renamer_2 (flit_in_if_yp, flit_in_if[2]);
  tnoc_flit_if_renamer u_flit_if_renamer_3 (flit_in_if_ym, flit_in_if[3]);
  tnoc_flit_if_renamer u_flit_if_renamer_4 (flit_in_if_l , flit_in_if[4]);

  tnoc_port_control_if_renamer u_port_control_if_renamer_0 (port_control_if_xp, port_control_if[0]);
  tnoc_port_control_if_renamer u_port_control_if_renamer_1 (port_control_if_xm, port_control_if[1]);
  tnoc_port_control_if_renamer u_port_control_if_renamer_2 (port_control_if_yp, port_control_if[2]);
  tnoc_port_control_if_renamer u_port_control_if_renamer_3 (port_control_if_ym, port_control_if[3]);
  tnoc_port_control_if_renamer u_port_control_if_renamer_4 (port_control_if_l , port_control_if[4]);

  tnoc_port_controller #(
    .CONFIG (CONFIG )
  ) u_port_controller (
    .clk              (clk                      ),
    .rst_n            (rst_n                    ),
    .i_vc_available   (flit_out_if.vc_available ),
    .port_control_if  (port_control_if          ),
    .o_output_grant   (output_grant             ),
    .i_output_free    (output_free              )
  );

  tnoc_output_switch #(
    .CONFIG (CONFIG )
  ) u_output_switch (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .flit_in_if     (flit_in_if   ),
    .flit_out_if    (flit_out_if  ),
    .i_output_grant (output_grant ),
    .o_output_free  (output_free  )
  );
endmodule
