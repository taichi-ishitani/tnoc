`ifndef NOC_CONFIG_PKG_SV
`define NOC_CONFIG_PKG_SV
package noc_config_pkg;
  typedef struct {
    int address_width;
    int data_width;
    int id_x_width;
    int id_y_width;
    int tag_width;
    int length_width;
  } noc_config;

  parameter noc_config  NOC_DEFAULT_CONFIG  = '{
    address_width:  64,
    data_width:     256,
    id_x_width:     8,
    id_y_width:     8,
    length_width:   5,
    tag_width:      8
  };
endpackage
`endif
