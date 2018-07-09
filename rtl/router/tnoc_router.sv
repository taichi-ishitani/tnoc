module tnoc_router
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter   int         X               = 0,
  parameter   int         Y               = 0,
  parameter   bit [4:0]   AVAILABLE_PORTS = 5'b11111,
  localparam  int         LOCAL_PORTS     = CONFIG.virtual_channels
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
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS  = CONFIG.virtual_channels;

  `tnoc_internal_flit_if(CHANNELS)  flit_if[25]();
  tnoc_port_control_if #(CONFIG)    port_control_if[25]();

  for (genvar i = 0;i < 5;++i) begin : g_input
    `define instance_input_block(index, port_suffix) \
    if (i == index) begin : g_input``port_suffix`` \
      if (AVAILABLE_PORTS[i]) begin : g \
        localparam  tnoc_port_type  PORT_TYPE = (i == 4) ? TNOC_LOCAL_PORT : TNOC_INTERNAL_PORT; \
        tnoc_input_block #( \
          .CONFIG           (CONFIG           ), \
          .X                (X                ), \
          .Y                (Y                ), \
          .PORT_TYPE        (PORT_TYPE        ), \
          .AVAILABLE_PORTS  (AVAILABLE_PORTS  ) \
        ) u_input_block ( \
          .clk                (clk                        ), \
          .rst_n              (rst_n                      ), \
          .flit_in_if         (flit_in_if``port_suffix``  ), \
          .flit_out_if_xp     (flit_if[5*0+i]             ), \
          .flit_out_if_xm     (flit_if[5*1+i]             ), \
          .flit_out_if_yp     (flit_if[5*2+i]             ), \
          .flit_out_if_ym     (flit_if[5*3+i]             ), \
          .flit_out_if_l      (flit_if[5*4+i]             ), \
          .port_control_if_xp (port_control_if[5*0+i]     ), \
          .port_control_if_xm (port_control_if[5*1+i]     ), \
          .port_control_if_yp (port_control_if[5*2+i]     ), \
          .port_control_if_ym (port_control_if[5*3+i]     ), \
          .port_control_if_l  (port_control_if[5*4+i]     ) \
        ); \
      end \
      else begin : g_dummy \
        tnoc_input_block_dummy #( \
        .CONFIG (CONFIG ) \
        ) u_dummy ( \
          .flit_in_if         (flit_in_if``port_suffix``  ), \
          .flit_out_if_xp     (flit_if[5*0+i]             ), \
          .flit_out_if_xm     (flit_if[5*1+i]             ), \
          .flit_out_if_yp     (flit_if[5*2+i]             ), \
          .flit_out_if_ym     (flit_if[5*3+i]             ), \
          .flit_out_if_l      (flit_if[5*4+i]             ), \
          .port_control_if_xp (port_control_if[5*0+i]     ), \
          .port_control_if_xm (port_control_if[5*1+i]     ), \
          .port_control_if_yp (port_control_if[5*2+i]     ), \
          .port_control_if_ym (port_control_if[5*3+i]     ), \
          .port_control_if_l  (port_control_if[5*4+i]     ) \
        ); \
      end \
    end

    `instance_input_block(0, _x_plus )
    `instance_input_block(1, _x_minus)
    `instance_input_block(2, _y_plus )
    `instance_input_block(3, _y_minus)
    `instance_input_block(4, _local  )

    `undef  instance_input_block
  end

  for (genvar i = 0;i < 5;++i) begin : g_output
    `define instance_output_block(index, port_suffix) \
    if (i == index) begin : g_output``port_suffix`` \
      if (AVAILABLE_PORTS[i]) begin : g \
        localparam  tnoc_port_type  PORT_TYPE = (i == 4) ? TNOC_LOCAL_PORT : TNOC_INTERNAL_PORT; \
        tnoc_output_block #( \
          .CONFIG     (CONFIG     ), \
          .PORT_TYPE  (PORT_TYPE  ) \
        ) u_output_block ( \
          .clk                (clk                        ), \
          .rst_n              (rst_n                      ), \
          .flit_in_if_xp      (flit_if[5*i+0]             ), \
          .flit_in_if_xm      (flit_if[5*i+1]             ), \
          .flit_in_if_yp      (flit_if[5*i+2]             ), \
          .flit_in_if_ym      (flit_if[5*i+3]             ), \
          .flit_in_if_l       (flit_if[5*i+4]             ), \
          .flit_out_if        (flit_out_if``port_suffix`` ), \
          .port_control_if_xp (port_control_if[5*i+0]     ), \
          .port_control_if_xm (port_control_if[5*i+1]     ), \
          .port_control_if_yp (port_control_if[5*i+2]     ), \
          .port_control_if_ym (port_control_if[5*i+3]     ), \
          .port_control_if_l  (port_control_if[5*i+4]     ) \
        ); \
      end \
      else begin : g_dummy \
        tnoc_output_block_dummy #( \
          .CONFIG (CONFIG ) \
        ) u_dummy ( \
          .flit_in_if_xp      (flit_if[5*i+0]             ), \
          .flit_in_if_xm      (flit_if[5*i+1]             ), \
          .flit_in_if_yp      (flit_if[5*i+2]             ), \
          .flit_in_if_ym      (flit_if[5*i+3]             ), \
          .flit_in_if_l       (flit_if[5*i+4]             ), \
          .flit_out_if        (flit_out_if``port_suffix`` ), \
          .port_control_if_xp (port_control_if[5*i+0]     ), \
          .port_control_if_xm (port_control_if[5*i+1]     ), \
          .port_control_if_yp (port_control_if[5*i+2]     ), \
          .port_control_if_ym (port_control_if[5*i+3]     ), \
          .port_control_if_l  (port_control_if[5*i+4]     ) \
        ); \
      end \
    end

    `instance_output_block(0, _x_plus )
    `instance_output_block(1, _x_minus)
    `instance_output_block(2, _y_plus )
    `instance_output_block(3, _y_minus)
    `instance_output_block(4, _local  )

    `undef  instance_output_block
  end
endmodule
