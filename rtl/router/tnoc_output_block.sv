module tnoc_output_block
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
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
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS      = CONFIG.virtual_channels;
  localparam  int PORT_CHANNELS = (is_local_port(PORT_TYPE)) ? 1        : CHANNELS;
  localparam  int SWITCHES      = (is_local_port(PORT_TYPE)) ? CHANNELS : 1;

  `tnoc_internal_flit_if(PORT_CHANNELS) flit_in_if[5*SWITCHES]();
  `tnoc_internal_flit_if(PORT_CHANNELS) flit_switch_if[SWITCHES]();
  tnoc_port_control_if #(CONFIG)        port_control_if[5]();
  logic [4:0]                           output_grant[SWITCHES];
  logic                                 output_free[SWITCHES];

  `tnoc_port_control_if_renamer(port_control_if_xp, port_control_if[0]);
  `tnoc_port_control_if_renamer(port_control_if_xm, port_control_if[1]);
  `tnoc_port_control_if_renamer(port_control_if_yp, port_control_if[2]);
  `tnoc_port_control_if_renamer(port_control_if_ym, port_control_if[3]);
  `tnoc_port_control_if_renamer(port_control_if_l , port_control_if[4]);

  if (is_local_port(PORT_TYPE)) begin : g_input_local_port_renamer
    for (genvar i = 0;i < CHANNELS;++i) begin : g
      `define input_port_renamer(suffix, index) \
      assign  flit_in_if[5*i+index].valid           = flit_in_if_``suffix``.valid[i]; \
      assign  flit_in_if_``suffix``.ready[i]        = flit_in_if[5*i+index].ready; \
      assign  flit_in_if[5*i+index].flit[0]         = flit_in_if_``suffix``.flit[0]; \
      assign  flit_in_if_``suffix``.vc_available[i] = flit_in_if[5*i+index].vc_available;

      `input_port_renamer(xp, 0)
      `input_port_renamer(xm, 1)
      `input_port_renamer(yp, 2)
      `input_port_renamer(ym, 3)
      `input_port_renamer(l , 4)

      `undef  input_port_renamer
    end
  end
  else begin : g_input_internal_port_renamer
    `tnoc_flit_if_renamer(flit_in_if_xp, flit_in_if[0]);
    `tnoc_flit_if_renamer(flit_in_if_xm, flit_in_if[1]);
    `tnoc_flit_if_renamer(flit_in_if_yp, flit_in_if[2]);
    `tnoc_flit_if_renamer(flit_in_if_ym, flit_in_if[3]);
    `tnoc_flit_if_renamer(flit_in_if_l , flit_in_if[4]);
  end

  if (is_local_port(PORT_TYPE)) begin : g_local_port_contoller
    tnoc_local_port_controller #(CONFIG) u_port_controller (
      .clk              (clk                      ),
      .rst_n            (rst_n                    ),
      .i_vc_available   (flit_out_if.vc_available ),
      .port_control_if  (port_control_if          ),
      .o_output_grant   (output_grant             ),
      .i_output_free    (output_free              )
    );
  end
  else begin : g_internal_port_controller
    tnoc_internal_port_controller #(CONFIG) u_port_controller (
      .clk              (clk                      ),
      .rst_n            (rst_n                    ),
      .i_vc_available   (flit_out_if.vc_available ),
      .port_control_if  (port_control_if          ),
      .o_output_grant   (output_grant[0]          ),
      .i_output_free    (output_free[0]           )
    );
  end

  for (genvar i = 0;i < SWITCHES;++i) begin : g_switch
    tnoc_output_switch #(
      .CONFIG     (CONFIG         ),
      .PORT_TYPE  (PORT_TYPE      ),
      .CHANNELS   (PORT_CHANNELS  )
    ) u_output_switch (
      .clk            (clk                                  ),
      .rst_n          (rst_n                                ),
      .flit_in_if     (`tnoc_array_slicer(flit_in_if, i, 5) ),
      .flit_out_if    (flit_switch_if[i]                    ),
      .i_output_grant (output_grant[i]                      ),
      .o_output_free  (output_free[i]                       )
    );
  end

  if (is_local_port(PORT_TYPE)) begin : g_output_local_port_renamer
    tnoc_vc_mux #(CONFIG, PORT_TYPE) u_vc_mux (
      .i_vc_grant   ('0             ),
      .flit_in_if   (flit_switch_if ),
      .flit_out_if  (flit_out_if    )
    );
  end
  else begin : g_output_internal_port_renamer
    `tnoc_flit_if_renamer(flit_switch_if[0], flit_out_if)
  end
endmodule
