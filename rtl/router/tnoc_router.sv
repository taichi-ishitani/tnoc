module tnoc_router
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG          = TNOC_DEFAULT_CONFIG,
  parameter   bit [4:0]   AVAILABLE_PORTS = 5'b11111,
  localparam  int         LOCAL_PORTS     = CONFIG.virtual_channels,
  localparam  int         ID_X_WIDTH      = CONFIG.id_x_width,
  localparam  int         ID_Y_WIDTH      = CONFIG.id_y_width
)(
  input logic                   clk,
  input logic                   rst_n,
  input logic [ID_X_WIDTH-1:0]  i_id_x,
  input logic [ID_Y_WIDTH-1:0]  i_id_y,
  tnoc_flit_if.target           flit_in_if_x_plus,
  tnoc_flit_if.initiator        flit_out_if_x_plus,
  tnoc_flit_if.target           flit_in_if_x_minus,
  tnoc_flit_if.initiator        flit_out_if_x_minus,
  tnoc_flit_if.target           flit_in_if_y_plus,
  tnoc_flit_if.initiator        flit_out_if_y_plus,
  tnoc_flit_if.target           flit_in_if_y_minus,
  tnoc_flit_if.initiator        flit_out_if_y_minus,
  tnoc_flit_if.target           flit_in_if_local,
  tnoc_flit_if.initiator        flit_out_if_local
);
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS  = CONFIG.virtual_channels;

  `tnoc_internal_flit_if(CHANNELS)  flit_input_block_if[25]();
  tnoc_port_control_if #(CONFIG)    port_input_blck_control_if[25]();
  `tnoc_internal_flit_if(CHANNELS)  flit_output_block_if[25]();
  tnoc_port_control_if #(CONFIG)    port_output_blck_control_if[25]();

  function automatic tnoc_port_type get_port_type(int index);
    return (index == 4) ? TNOC_LOCAL_PORT : TNOC_INTERNAL_PORT;
  endfunction

  `define tnoc_instance_input_block(index, port_suffix) \
  if (AVAILABLE_PORTS[index]) begin : g_input_block``port_suffix \
    tnoc_input_block #( \
      .CONFIG           (CONFIG               ), \
      .PORT_TYPE        (get_port_type(index) ), \
      .AVAILABLE_PORTS  (AVAILABLE_PORTS      ) \
    ) u_input_block ( \
      .clk              (clk                                                      ), \
      .rst_n            (rst_n                                                    ), \
      .i_id_x           (i_id_x                                                   ), \
      .i_id_y           (i_id_y                                                   ), \
      .flit_in_if       (flit_in_if``port_suffix                                  ), \
      .flit_out_if      (`tnoc_array_slicer(flit_input_block_if       , index, 5) ), \
      .port_control_if  (`tnoc_array_slicer(port_input_blck_control_if, index, 5) ) \
    ); \
  end \
  else begin : g_dummy_input_block``port_suffix \
    tnoc_input_block_dummy #( \
    .CONFIG (CONFIG ) \
    ) u_dummy ( \
      .flit_in_if       (flit_in_if``port_suffix                                  ), \
      .flit_out_if      (`tnoc_array_slicer(flit_input_block_if       , index, 5) ), \
      .port_control_if  (`tnoc_array_slicer(port_input_blck_control_if, index, 5) ) \
    ); \
  end

  `tnoc_instance_input_block(0, _x_plus )
  `tnoc_instance_input_block(1, _x_minus)
  `tnoc_instance_input_block(2, _y_plus )
  `tnoc_instance_input_block(3, _y_minus)
  `tnoc_instance_input_block(4, _local  )

  `undef  tnoc_instance_input_block

  for (genvar i = 0;i < 5;++i) begin
    for (genvar j = 0;j < 5;++j) begin
      `tnoc_flit_if_renamer(flit_input_block_if[5*i+j], flit_output_block_if[5*j+i])
      `tnoc_port_control_if_renamer(port_input_blck_control_if[5*i+j], port_output_blck_control_if[5*j+i])
    end
  end

  `define tnoc_instance_output_block(index, port_suffix) \
  if (AVAILABLE_PORTS[index]) begin : g_output_block``port_suffix \
    tnoc_output_block #( \
      .CONFIG     (CONFIG               ), \
      .PORT_TYPE  (get_port_type(index) ) \
    ) u_output_block ( \
      .clk              (clk                                                        ), \
      .rst_n            (rst_n                                                      ), \
      .flit_in_if       (`tnoc_array_slicer(flit_output_block_if, index, 5)         ), \
      .flit_out_if      (flit_out_if``port_suffix                                   ), \
      .port_control_if  (`tnoc_array_slicer(port_output_blck_control_if, index, 5)  ) \
    ); \
  end \
  else begin : g_dummy_output_block``port_suffix \
    tnoc_output_block_dummy #( \
      .CONFIG (CONFIG ) \
    ) u_dummy ( \
      .flit_in_if       (`tnoc_array_slicer(flit_output_block_if, index, 5)         ), \
      .flit_out_if      (flit_out_if``port_suffix                                   ), \
      .port_control_if  (`tnoc_array_slicer(port_output_blck_control_if, index, 5)  ) \
    ); \
  end

  `tnoc_instance_output_block(0, _x_plus )
  `tnoc_instance_output_block(1, _x_minus)
  `tnoc_instance_output_block(2, _y_plus )
  `tnoc_instance_output_block(3, _y_minus)
  `tnoc_instance_output_block(4, _local  )

  `undef  tnoc_instance_output_block
endmodule
