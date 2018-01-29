module noc_output_block
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)(
  input logic clk,
  input logic rst_n,
  noc_flit_if.target              flit_in_if_xp,
  noc_flit_if.target              flit_in_if_xm,
  noc_flit_if.target              flit_in_if_yp,
  noc_flit_if.target              flit_in_if_ym,
  noc_flit_if.target              flit_in_if_l,
  noc_flit_if.initiator           flit_out_if,
  noc_port_control_if.arbitrator  port_control_if_xp,
  noc_port_control_if.arbitrator  port_control_if_xm,
  noc_port_control_if.arbitrator  port_control_if_yp,
  noc_port_control_if.arbitrator  port_control_if_ym,
  noc_port_control_if.arbitrator  port_control_if_l
);
  localparam  int CHANNELS  = CONFIG.virtual_channels;

  noc_flit_if #(CONFIG)         flit_in_if[5]();
  noc_port_control_if #(CONFIG) port_control_if[5]();
  logic [4:0]                   output_grant;
  logic                         output_free;

  noc_flit_if_renamer u_flit_if_renamer_0 (flit_in_if_xp, flit_in_if[0]);
  noc_flit_if_renamer u_flit_if_renamer_1 (flit_in_if_xm, flit_in_if[1]);
  noc_flit_if_renamer u_flit_if_renamer_2 (flit_in_if_yp, flit_in_if[2]);
  noc_flit_if_renamer u_flit_if_renamer_3 (flit_in_if_ym, flit_in_if[3]);
  noc_flit_if_renamer u_flit_if_renamer_4 (flit_in_if_l , flit_in_if[4]);

  noc_port_control_if_renamer u_port_control_if_renamer_0 (port_control_if_xp, port_control_if[0]);
  noc_port_control_if_renamer u_port_control_if_renamer_1 (port_control_if_xm, port_control_if[1]);
  noc_port_control_if_renamer u_port_control_if_renamer_2 (port_control_if_yp, port_control_if[2]);
  noc_port_control_if_renamer u_port_control_if_renamer_3 (port_control_if_ym, port_control_if[3]);
  noc_port_control_if_renamer u_port_control_if_renamer_4 (port_control_if_l , port_control_if[4]);

  noc_port_controller #(
    .CONFIG (CONFIG )
  ) u_port_controller (
    .clk              (clk                      ),
    .rst_n            (rst_n                    ),
    .i_vc_available   (flit_out_if.vc_available ),
    .port_control_if  (port_control_if          ),
    .o_output_grant   (output_grant             ),
    .i_output_free    (output_free              )
  );

  noc_output_switch #(
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
