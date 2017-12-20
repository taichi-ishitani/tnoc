`ifndef NOC_BFM_PACKET_ITEM_SVH
`define NOC_BFM_PACKET_ITEM_SVH
typedef tue_sequence_item #(
  noc_bfm_configuration, noc_bfm_status
) noc_bfm_packet_item_base;

class noc_bfm_packet_item extends noc_bfm_packet_item_base;
  typedef struct {
    int               width;
    noc_bfm_flit_data data;
  } s_data_packer;

  rand  noc_bfm_packet_type     packet_type;
  rand  noc_bfm_location_id     destination_id;
  rand  noc_bfm_location_id     source_id;
  rand  noc_bfm_vc              virtual_channel;
  rand  noc_bfm_tag             tag;
  rand  int                     length;
  rand  noc_bfm_address         address;
  rand  noc_bfm_response_status status;
  rand  noc_bfm_lower_address   lower_address;
  rand  bit                     last_response;
  rand  noc_bfm_data            data[];
  rand  noc_bfm_byte_enable     byte_enable[];

        int                     tr_handle;

  constraint c_default_source_id {
    soft source_id.x == configuration.id_x;
    soft source_id.y == configuration.id_y;
  }

  constraint c_valid_virtual_channel {
    solve packet_type before virtual_channel;
    virtual_channel < configuration.virtual_channels;
  }

  constraint c_default_virtual_channel {
    if (packet_type inside {NOC_BFM_RESPONSE, NOC_BFM_RESPONSE_WITH_DATA}) {
      soft virtual_channel == 0;
    }
    else {
      soft virtual_channel == 1;
    }
  }

  constraint c_valid_tag {
    tag < 2**configuration.tag_width;
  }

  constraint c_valid_length {
    length inside {[1:2**configuration.length_width]};
  }

  constraint c_valid_status {
    solve packet_type before status;
    if (!packet_type[1]) {
      status == NOC_BFM_OKAY;
    }
  }

  constraint c_defualt_status {
    if (packet_type[7]) {
      soft status == NOC_BFM_OKAY;
    }
  }

  constraint c_valid_lower_address {
    solve packet_type before lower_address;
    if (packet_type[7]) {
      lower_address < 2**configuration.lower_address_width;
    }
    else {
      lower_address == 0;
    }
  }

  constraint c_valid_last_response {
    solve packet_type before last_response;
    if (!packet_type[7]) {
      last_response == 0;
    }
  }

  constraint c_valid_data {
    solve packet_type, length before data;
    if (packet_type[6]) {
      data.size == length;
      foreach (data[i]) {
        (data[i] >> configuration.data_width) == 0;
      }
    }
    else {
      data.size == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve packet_type, length before byte_enable;
    if ((!packet_type[7]) && packet_type[6]) {
      byte_enable.size == length;
      foreach (byte_enable[i]) {
        (byte_enable[i] >> configuration.byte_enable_width) == 0;
      }
    }
    else {
      byte_enable.size == 0;
    }
  }

  function bit is_request;
    return (!packet_type[7]) ? '1 : '0;
  endfunction

  function bit is_response;
    return (packet_type[7]) ? '1 : '0;
  endfunction

  function bit has_payload();
    return (packet_type[6]) ? '1 : '0;
  endfunction

  function void pack_flits(ref noc_bfm_flit flits[$]);
    flits.push_back(get_header_flit());
    foreach (data[i]) begin
      flits.push_back(get_payload_flit(i));
    end
  endfunction

  function void pack_flit_items(ref noc_bfm_flit_item flit_items[$]);
    noc_bfm_flit  flits[$];
    pack_flits(flits);
    foreach (flits[i]) begin
      noc_bfm_flit_item flit_item;
      flit_item = noc_bfm_flit_item::type_id::create($sformatf("flit_item[%0d]", i));
      flit_item.unpack_flit(flits[i]);
      flit_items.push_back(flit_item);
    end
  endfunction

  function void unpack_flits(const ref noc_bfm_flit flits[$]);
    unpack_header_flit(flits[0]);

    if (!has_payload()) begin
      return;
    end

    data  = new[length];
    if (is_request()) begin
      byte_enable = new[length];
    end

    foreach (data[i]) begin
      unpack_payload_flit(flits[i+1], i);
    end
  endfunction

  function void unpack_flit_items(const ref noc_bfm_flit_item flit_items[$]);
    noc_bfm_flit  flits[$];
    foreach (flit_items[i]) begin
      flits.push_back(flit_items[i].get_flit());
    end
    unpack_flits(flits);
  endfunction

  local function noc_bfm_flit get_header_flit();
    noc_bfm_flit  flit;
    s_data_packer data_packer[$];

    data_packer.push_back('{data: packet_type     , width: 8                         });
    data_packer.push_back('{data: destination_id.y, width: configuration.id_y_width  });
    data_packer.push_back('{data: destination_id.x, width: configuration.id_x_width  });
    data_packer.push_back('{data: source_id.y     , width: configuration.id_y_width  });
    data_packer.push_back('{data: source_id.x     , width: configuration.id_x_width  });
    data_packer.push_back('{data: virtual_channel , width: configuration.vc_width    });
    data_packer.push_back('{data: tag             , width: configuration.tag_width   });
    data_packer.push_back('{data: length          , width: configuration.length_width});
    if (is_request()) begin
      data_packer.push_back('{data: address, width: configuration.address_width});
    end
    else begin
      data_packer.push_back('{data: status       , width: 2                                });
      data_packer.push_back('{data: lower_address, width: configuration.lower_address_width});
      data_packer.push_back('{data: last_response, width: 1                                });
    end

    flit.flit_type  = NOC_BFM_HEADER_FLIT;
    flit.data       = pack_flit_data(data_packer);
    flit.tail       = (!packet_type[6]) ? '1 : '0;

    return flit;
  endfunction

  local function void unpack_header_flit(const ref noc_bfm_flit flit);
    s_data_packer data_packer[$];

    packet_type = noc_bfm_packet_type'(flit.data[7:0]);

    data_packer.push_back('{data: '0, width: configuration.id_y_width  });
    data_packer.push_back('{data: '0, width: configuration.id_x_width  });
    data_packer.push_back('{data: '0, width: configuration.id_y_width  });
    data_packer.push_back('{data: '0, width: configuration.id_x_width  });
    data_packer.push_back('{data: '0, width: configuration.vc_width    });
    data_packer.push_back('{data: '0, width: configuration.tag_width   });
    data_packer.push_back('{data: '0, width: configuration.length_width});
    if (is_request()) begin
      data_packer.push_back('{data: '0, width: configuration.address_width});
    end
    else begin
      data_packer.push_back('{data: '0, width: 2                                });
      data_packer.push_back('{data: '0, width: configuration.lower_address_width});
      data_packer.push_back('{data: '0, width: 1                                });
    end

    unpack_flit_data(flit, data_packer, 8);

    destination_id  = '{y: data_packer[0].data, x: data_packer[1].data};
    source_id       = '{y: data_packer[2].data, x: data_packer[3].data};
    virtual_channel = data_packer[4].data;
    tag             = data_packer[5].data;
    length          = (data_packer[6].data == 0) ? 2**configuration.length_width : data_packer[6].data;
    if (is_request()) begin
      address = data_packer[7].data;
    end
    else begin
      status        = noc_bfm_response_status'(data_packer[7].data);
      lower_address = data_packer[8].data;
      last_response = data_packer[9].data;
    end
  endfunction

  local function noc_bfm_flit get_payload_flit(int index);
    noc_bfm_flit  flit;
    s_data_packer data_packer[$];

    data_packer.push_back('{data: data[index], width: configuration.data_width});
    if (is_request()) begin
      data_packer.push_back('{data: byte_enable[index], width: configuration.byte_enable_width});
    end

    flit.flit_type  = NOC_BFM_PAYLOAD_FLIT;
    flit.data       = pack_flit_data(data_packer);
    flit.tail       = (index == (length - 1)) ? '1 : '0;

    return flit;
  endfunction

  local function void unpack_payload_flit(const ref noc_bfm_flit flit, input int index);
    s_data_packer data_packer[$];

    data_packer.push_back('{data: '0, width: configuration.data_width});
    if (is_request()) begin
      data_packer.push_back('{data: '0, width: configuration.byte_enable_width});
    end

    unpack_flit_data(flit, data_packer);

    data[index] = data_packer[0].data;
    if (is_request()) begin
      byte_enable[index]  = data_packer[1].data;
    end
  endfunction

  local function noc_bfm_flit_data pack_flit_data(ref s_data_packer data_packer[$]);
    noc_bfm_flit_data data      = '0;
    int               position  = 0;

    foreach (data_packer[i]) begin
      noc_bfm_flit_data mask  = (1 << data_packer[i].width) - 1;
      data      |= ((data_packer[i].data & mask) << position);
      position  += data_packer[i].width;
    end

    return data;
  endfunction

  local function void unpack_flit_data(
    const ref   noc_bfm_flit  flit,
          ref   s_data_packer data_packer[$],
          input int           offset  = 0
  );
    int position  = offset;
    foreach (data_packer[i]) begin
      noc_bfm_flit_data mask  = (1 << data_packer[i].width) - 1;
      data_packer[i].data = (flit.data >> position) & mask;
      position  += data_packer[i].width;
    end
  endfunction

  `tue_object_default_constructor(noc_bfm_packet_item)
  `uvm_object_utils_begin(noc_bfm_packet_item)
    `uvm_field_enum(noc_bfm_packet_type, packet_type, UVM_DEFAULT)
    `uvm_field_int(destination_id , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(source_id      , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(virtual_channel, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tag            , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address        , UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(noc_bfm_response_status, status, UVM_DEFAULT)
    `uvm_field_int(lower_address  , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(last_response  , UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(data       , UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
`endif
