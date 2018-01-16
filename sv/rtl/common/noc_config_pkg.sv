`ifndef NOC_CONFIG_PKG_SV
`define NOC_CONFIG_PKG_SV
package noc_config_pkg;
  typedef struct {
    int address_width;
    int data_width;
    int id_x_width;
    int id_y_width;
    int vc_width;
    int tag_width;
    int length_width;
    int virtual_channels;
    int input_fifo_depth;
    int size_x;
    int size_y;
  } noc_config;

  parameter noc_config  NOC_DEFAULT_CONFIG  = '{
    address_width:    64,
    data_width:       256,
    id_x_width:       8,
    id_y_width:       8,
    vc_width:         3,
    length_width:     5,
    tag_width:        8,
    virtual_channels: 2,
    input_fifo_depth: 8,
    size_x:           3,
    size_y:           3
  };
endpackage
`endif
