`ifndef TNOC_CONFIG_PKG_SV
`define TNOC_CONFIG_PKG_SV
package tnoc_config_pkg;
  `include  "tnoc_defines.svh"

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

  localparam tnoc_config TNOC_DEFAULT_CONFIG = '{
    address_width:    `TNOC_DEFAULT_ADDRESS_WIDTH,
    data_width:       `TNOC_DEFAULT_DATA_WIDTH,
    id_x_width:       `TNOC_DEFAULT_ID_X_WIDTH,
    id_y_width:       `TNOC_DEFAULT_ID_Y_WIDTH,
    virtual_channels: `TNOC_DEFAULT_VIRTUAL_CHANNELS,
    tags:             `TNOC_DEFAULT_TAGS,
    max_burst_length: `TNOC_DEFAULT_MAX_BURST_LENGTH,
    input_fifo_depth: `TNOC_DEFAULT_FIFO_DEPTH,
    size_x:           `TNOC_DEFAULT_SIZE_X,
    size_y:           `TNOC_DEFAULT_SIZE_Y,
    error_data:       `TNOC_DEFAULT_ERROR_DATA
  };
endpackage
`endif
