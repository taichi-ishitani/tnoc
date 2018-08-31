`ifndef TNOC_CONFIG_PKG_SV
`define TNOC_CONFIG_PKG_SV

`ifndef TNOC_MAX_DATA_WIDTH
  `define TNOC_MAX_DATA_WIDTH 256
`endif

package tnoc_config_pkg;
  typedef struct packed {
    int                             address_width;
    int                             data_width;
    int                             id_x_width;
    int                             id_y_width;
    int                             virtual_channels;
    int                             tags;
    int                             max_burst_length;
    int                             input_fifo_depth;
    int                             size_x;
    int                             size_y;
    bit [`TNOC_MAX_DATA_WIDTH-1:0]  error_data;
  } tnoc_config;

  parameter tnoc_config TNOC_DEFAULT_CONFIG = '{
    address_width:    64,
    data_width:       256,
    id_x_width:       5,
    id_y_width:       5,
    virtual_channels: 2,
    tags:             256,
    max_burst_length: 256,
    input_fifo_depth: 8,
    size_x:           3,
    size_y:           3,
    error_data:       '1
  };
endpackage
`endif
