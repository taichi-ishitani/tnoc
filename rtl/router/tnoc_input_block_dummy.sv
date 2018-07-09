module tnoc_input_block_dummy
  `include  "tnoc_default_imports.svh"
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
  tnoc_port_control_if.requester  port_control_if_ym,
  tnoc_port_control_if.requester  port_control_if_l
);
  `include  "tnoc_macros.svh"

  `tnoc_internal_flit_if(CONFIG.virtual_channels) flit_out_if[5]();
  tnoc_port_control_if #(CONFIG)                  port_control_if[5]();

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

  assign  flit_in_if.ready        = '0;
  assign  flit_in_if.vc_available = '0;

  for (genvar i = 0;i < 5;++i) begin
    assign  flit_out_if[i].valid  = '0;
    for (genvar j = 0;j < CONFIG.virtual_channels;++j) begin
      assign  flit_out_if[i].flit[j]  = '0;
    end

    assign  port_control_if[i].request          = '0;
    assign  port_control_if[i].free             = '0;
    assign  port_control_if[i].start_of_packet  = '0;
    assign  port_control_if[i].end_of_packet    = '0;
  end
endmodule
