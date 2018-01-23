`ifndef NOC_BFM_CONFIGURATION_SVH
`define NOC_BFM_CONFIGURATION_SVH
class noc_bfm_configuration extends tue_configuration;
  rand  int               address_width;
  rand  int               data_width;
  rand  int               byte_enable_width;
  rand  int               id_x_width;
  rand  int               id_y_width;
  rand  int               vc_width;
  rand  int               id_width;
  rand  int               tag_width;
  rand  int               length_width;
  rand  int               lower_address_width;
  rand  int               virtual_channels;
  rand  int               id_x;
  rand  int               id_y;
        noc_bfm_flit_vif  tx_vif;
        noc_bfm_flit_vif  rx_vif;

  local int               common_header_width;
  local int               request_header_width;
  local int               resposne_header_width;
  local int               header_width;
  local int               payload_width;
  local int               flit_width;

  constraint c_valid_address_width {
    address_width inside {[1:`NOC_BFM_MAX_ADDRESS_WIDTH]};
  }

  constraint c_valid_data_width {
    data_width inside {[8:`NOC_BFM_MAX_DATA_WIDTH]};
    $countones(data_width) == 1;
  }

  constraint c_default_byte_enable_width {
    solve data_width before byte_enable_width;
    soft byte_enable_width == (data_width / 8);
  }

  constraint c_valid_id_width {
    id_x_width inside {[1:`NOC_BFM_MAX_ID_X_WIDTH]};
    id_y_width inside {[1:`NOC_BFM_MAX_ID_Y_WIDTH]};
    id_width == (id_x_width + id_y_width);
  }

  constraint c_valid_vc_width {
    vc_width inside {[1:`NOC_BFM_MAX_VC_WIDTH]};
  }

  constraint c_valid_tag_width {
    tag_width inside {[1:`NOC_BFM_MAX_TAG_WIDTH]};
  }

  constraint c_valid_length_width {
    length_width inside {[1:`NOC_BFM_MAX_LENGTH_WIDTH]};
  }

  constraint c_default_lower_address {
    solve data_width before lower_address_width;
    soft lower_address_width == $clog2(data_width / 8);
  }

  constraint c_valid_virtual_channels {
    solve vc_width before virtual_channels;
    virtual_channels inside {[1:2**vc_width]};
  }

  constraint c_valid_id {
    solve id_x_width before id_x;
    solve id_y_width before id_y;
    id_x inside {[0:(2**id_x_width)-1]};
    id_y inside {[0:(2**id_y_width)-1]};
  }

  function int get_common_header_width();
    if (common_header_width <= 0) begin
      common_header_width = (
        8                         + //  Packet Type
        (id_y_width + id_x_width) + //  Destination ID
        (id_y_width + id_x_width) + //  Source ID
        vc_width                  + //  Virtual Channel
        tag_width                 + //  Packet Tag
        length_width              + //  Length
        1                           //  Invalid Destination Flag
      );
    end
    return common_header_width;
  endfunction

  function int get_request_header_width();
    if (request_header_width <= 0) begin
      request_header_width  = (
        get_common_header_width() + //  Common Fields
        address_width               //  Address
      );
    end
    return request_header_width;
  endfunction

  function int get_response_header_width();
    if (resposne_header_width <= 0) begin
      resposne_header_width = (
        get_common_header_width() + //  Common Fields
        2                         + //  Status
        lower_address_width       + //  Lower Address
        1                           //  Last Response Flag
      );
    end
    return resposne_header_width;
  endfunction

  function int get_header_width();
    if (header_width <= 0) begin
      if (get_request_header_width() > get_response_header_width()) begin
        header_width  = get_request_header_width();
      end
      else begin
        header_width  = get_response_header_width();
      end
    end
    return header_width;
  endfunction

  function int get_payload_width();
    if (payload_width <= 0) begin
      payload_width = data_width + byte_enable_width;
    end
    return payload_width;
  endfunction

  function int get_flit_width();
    if (flit_width <= 0) begin
      if (get_common_header_width() > get_payload_width()) begin
        flit_width  = get_common_header_width();
      end
      else begin
        flit_width  = get_payload_width();
      end
    end
    return flit_width;
  endfunction

  `tue_object_default_constructor(noc_bfm_configuration)
  `uvm_object_utils_begin(noc_bfm_configuration)
    `uvm_field_int(address_width      , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(byte_enable_width  , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_x_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_y_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(vc_width           , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tag_width          , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(length_width       , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(lower_address_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(virtual_channels   , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_x               , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_y               , UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
`endif
