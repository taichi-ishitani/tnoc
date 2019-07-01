`ifndef TNOC_BFM_CONFIGURATION_SVH
`define TNOC_BFM_CONFIGURATION_SVH
class tnoc_bfm_configuration extends tue_configuration;
  rand  uvm_active_passive_enum agent_mode;
  rand  int                     address_width;
  rand  int                     data_width;
  rand  int                     byte_enable_width;
  rand  int                     id_x_width;
  rand  int                     id_y_width;
  rand  int                     id_width;
  rand  int                     virtual_channels;
  rand  int                     vc_map[tnoc_bfm_packet_type];
  rand  int                     vc_width;
  rand  int                     tags;
  rand  int                     tag_width;
  rand  int                     max_burst_length;
  rand  int                     burst_length_width;
        int                     burst_size_width;
  rand  int                     id_x;
  rand  int                     id_y;
        tnoc_bfm_flit_vif       tx_vif[int];
        tnoc_bfm_flit_vif       rx_vif[int];

  local int               common_header_width;
  local int               request_header_width;
  local int               resposne_header_width;
  local int               header_width;
  local int               write_payload_width;
  local int               read_payload_width;
  local int               payload_width;
  local int               flit_width;

  constraint c_default_agent_mode {
    soft agent_mode == UVM_ACTIVE;
  }

  constraint c_valid_address_width {
    address_width inside {[1:`TNOC_BFM_MAX_ADDRESS_WIDTH]};
  }

  constraint c_valid_data_width {
    data_width inside {[8:`TNOC_BFM_MAX_DATA_WIDTH]};
    $countones(data_width) == 1;
  }

  constraint c_default_byte_enable_width {
    solve data_width before byte_enable_width;
    soft byte_enable_width == (data_width / 8);
  }

  constraint c_valid_id_width {
    id_x_width inside {[1:`TNOC_BFM_MAX_ID_X_WIDTH]};
    id_y_width inside {[1:`TNOC_BFM_MAX_ID_Y_WIDTH]};
    id_width == (id_x_width + id_y_width);
  }

  constraint c_valid_virtual_channels {
    virtual_channels inside {[1:`TNOC_BFM_MAX_VIRTUAL_CHANNELS]};
  }

  constraint c_valid_vc_map {
    solve virtual_channels before vc_map;
    foreach (vc_map[packet_type]) {
      vc_map[packet_type] inside {-1, [0:virtual_channels-1]};
    }
  }

  constraint c_default_vc_map {
    foreach (vc_map[packet_type]) {
      soft vc_map[packet_type] == -1;
    }
  }

  constraint c_valid_vc_width {
    solve virtual_channels before vc_width;
    if (virtual_channels == 1) {
      vc_width == 1;
    }
    else {
      vc_width == $clog2(virtual_channels);
    }
  }

  constraint c_valid_tags {
    tags inside {[1:`TNOC_BFM_MAX_TAGS]};
  }

  constraint c_valid_tag_width {
    solve tags before tag_width;
    if (tags == 1) {
      tag_width == 1;
    }
    else {
      tag_width == $clog2(tags);
    }
  }

  constraint c_valid_max_bursts {
    max_burst_length inside {[1:`TNOC_BFM_MAX_BURST_LENGTH]};
  }

  constraint c_valid_burst_length {
    solve max_burst_length before burst_length_width;
    if (max_burst_length == 1) {
      burst_length_width == 1;
    }
    else {
      burst_length_width == $clog2(max_burst_length);
    }
  }

  constraint c_valid_id {
    solve id_x_width before id_x;
    solve id_y_width before id_y;
    id_x inside {[0:(2**id_x_width)-1]};
    id_y inside {[0:(2**id_y_width)-1]};
  }

  function new(string name = "tnoc_bfm_configuration");
    super.new(name);
    setup_default_vc_map();
  endfunction

  function void post_randomize();
    burst_size_width  = (data_width <= 16) ? 1 : $clog2($clog2(data_width / 8));
  endfunction

  function int get_common_header_width();
    if (common_header_width <= 0) begin
      common_header_width = (
        8                         +  //  Packet Type
        (id_y_width + id_x_width) +  //  Destination ID
        (id_y_width + id_x_width) +  //  Source ID
        vc_width                  +  //  Virtual Channel
        tag_width                 +  //  Packet Tag
        1                            //  Invalid Destination Flag
      );
    end
    return common_header_width;
  endfunction

  function int get_request_header_width();
    if (request_header_width <= 0) begin
      request_header_width  = (
        get_common_header_width()  +  //  Common Fields
        $bits(tnoc_bfm_burst_type) +  //  burst type
        burst_length_width         +  //  burst length
        burst_size_width           +  //  burst size
        address_width                 //  Address
      );
    end
    return request_header_width;
  endfunction

  function int get_response_header_width();
    if (resposne_header_width <= 0) begin
      resposne_header_width = (
        get_common_header_width() +     //  Common Fields
        $bits(tnoc_bfm_response_status) //  status
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

  function int get_write_payload_width();
    if (write_payload_width <= 0) begin
      write_payload_width = data_width + byte_enable_width;
    end
    return write_payload_width;
  endfunction

  function int get_read_payload_width();
    if (read_payload_width <= 0) begin
      read_payload_width  = data_width + $bits(tnoc_bfm_response_status);
    end
    return read_payload_width;
  endfunction

  function int get_payload_width();
    if (payload_width <= 0) begin
      if (get_write_payload_width() > get_read_payload_width()) begin
        payload_width = get_write_payload_width();
      end
      else begin
        payload_width = get_read_payload_width();
      end
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

  local function void setup_default_vc_map();
    tnoc_bfm_packet_type  packet_type;
    packet_type = packet_type.first();
    while (1) begin
      vc_map[packet_type] = -1;
      if (packet_type == packet_type.last()) begin
        break;
      end
      else begin
        packet_type = packet_type.next();
      end
    end
  endfunction

  `uvm_object_utils_begin(tnoc_bfm_configuration)
    `uvm_field_enum(uvm_active_passive_enum, agent_mode, UVM_DEFAULT)
    `uvm_field_int(address_width      , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(byte_enable_width  , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_x_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_y_width         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(virtual_channels   , UVM_DEFAULT | UVM_DEC)
    `uvm_field_aa_int_enumkey(tnoc_bfm_packet_type, vc_map, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(vc_width           , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tags               , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tag_width          , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_burst_length   , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(burst_length_width , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(burst_size_width   , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_x               , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id_y               , UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
`endif
