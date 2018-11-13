module tnoc_output_block
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  input logic                     clk,
  input logic                     rst_n,
  tnoc_flit_if.target             flit_in_if[5],
  tnoc_flit_if.initiator          flit_out_if,
  tnoc_port_control_if.arbitrator port_control_if[5]
);
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS      = CONFIG.virtual_channels;
  localparam  int PORT_CHANNELS = (is_local_port(PORT_TYPE)) ? 1        : CHANNELS;
  localparam  int SWITCHES      = (is_local_port(PORT_TYPE)) ? CHANNELS : 1;

  `tnoc_internal_flit_if(PORT_CHANNELS) flit_switch_in_if[5*SWITCHES]();
  `tnoc_internal_flit_if(PORT_CHANNELS) flit_switch_out_if[SWITCHES]();
  logic [4:0]                           output_grant[SWITCHES];
  logic                                 output_free[SWITCHES];

  if (is_local_port(PORT_TYPE)) begin
    for (genvar i = 0;i < CHANNELS;++i) begin
      for (genvar j = 0;j < 5;++j) begin
        assign  flit_switch_in_if[5*i+j].valid    = flit_in_if[j].valid[i];
        assign  flit_in_if[j].ready[i]            = flit_switch_in_if[5*i+j].ready;
        assign  flit_switch_in_if[5*i+j].flit[0]  = flit_in_if[j].flit[0];
        assign  flit_in_if[j].vc_available[i]     = flit_switch_in_if[5*i+j].vc_available;
      end
    end
  end
  else begin
    for (genvar i = 0;i < 5;++i) begin
      `tnoc_flit_if_renamer(flit_in_if[i], flit_switch_in_if[i])
    end
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
      .clk            (clk                                          ),
      .rst_n          (rst_n                                        ),
      .flit_in_if     (`tnoc_array_slicer(flit_switch_in_if, i, 5)  ),
      .flit_out_if    (flit_switch_out_if[i]                        ),
      .i_output_grant (output_grant[i]                              ),
      .o_output_free  (output_free[i]                               )
    );
  end

  if (is_local_port(PORT_TYPE)) begin : g_output_local_port_renamer
    tnoc_vc_mux #(CONFIG, PORT_TYPE) u_vc_mux (
      .i_vc_grant   ('0                 ),
      .flit_in_if   (flit_switch_out_if ),
      .flit_out_if  (flit_out_if        )
    );
  end
  else begin : g_output_internal_port_renamer
    `tnoc_flit_if_renamer(flit_switch_out_if[0], flit_out_if)
  end
endmodule
