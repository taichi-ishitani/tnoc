`ifndef TNOC_CONFIG_PKG_SV
`define TNOC_CONFIG_PKG_SV
package tnoc_config_pkg;
  `include  "tnoc_config_defines.svh"

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
/*
  //  Xcelium simulator does not support constant system function call inside constant function call
  function automatic int get_vc_width(tnoc_config noc_config);
    if (noc_config.virtual_channels == 1) begin
      return 1;
    end
    else begin
      return $clog2(noc_config.virtual_channels);
    end
  endfunction

  function automatic int get_tag_width(tnoc_config noc_config);
    if (noc_config.tags == 1) begin
      return 1;
    end
    else begin
      return $clog2(noc_config.tags);
    end
  endfunction

  function automatic int get_packed_burst_length_width(tnoc_config noc_config);
    if (noc_config.max_burst_length == 1) begin
      return 1;
    end
    else begin
      return $clog2(noc_config.max_burst_length);
    end
  endfunction

  function automatic int get_unpacked_burst_length_width(tnoc_config noc_config);
    return $clog2(noc_config.max_burst_length + 1);
  endfunction

  function automatic int get_burst_size_width(tnoc_config noc_config);
    if (noc_config.data_width == 8) begin
      return 1;
    end
    else begin
      return $clog2($clog2(noc_config.data_width) - 3);
    end
  endfunction
*/
endpackage
`endif
