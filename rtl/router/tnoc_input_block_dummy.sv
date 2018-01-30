module tnoc_input_block_dummy
  import  tnoc_config_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)(
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

  assign  flit_in_if.ready        = '0;
  assign  flit_in_if.vc_available = '0;

  generate for (genvar i = 0;i < 5;++i) begin
    assign  flit_out_if[i].valid  = '0;
    assign  flit_out_if[i].flit   = '0;

    assign  port_control_if[i].request          = '0;
    assign  port_control_if[i].free             = '0;
    assign  port_control_if[i].start_of_packet  = '0;
    assign  port_control_if[i].end_of_packet    = '0;
  end endgenerate
endmodule
