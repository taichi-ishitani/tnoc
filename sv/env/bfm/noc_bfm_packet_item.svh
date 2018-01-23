`ifndef NOC_BFM_PACKET_ITEM_SVH
`define NOC_BFM_PACKET_ITEM_SVH
typedef tue_sequence_item #(
  noc_bfm_configuration, noc_bfm_status
) noc_bfm_packet_item_base;

class noc_bfm_packet_item extends noc_bfm_packet_item_base;
  rand  noc_bfm_packet_type     packet_type;
  rand  noc_bfm_location_id     destination_id;
  rand  noc_bfm_location_id     source_id;
  rand  noc_bfm_vc              virtual_channel;
  rand  noc_bfm_tag             tag;
  rand  int                     length;
  rand  bit                     invalid_destination;
  rand  noc_bfm_address         address;
  rand  noc_bfm_response_status status;
  rand  noc_bfm_lower_address   lower_address;
  rand  bit                     last_response;
  rand  noc_bfm_data            data[];
  rand  noc_bfm_byte_enable     byte_enable[];

        int                     tr_handle;

  static  uvm_packer  flit_packer;

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

  constraint c_default_invalid_destination {
    soft invalid_destination == 0;
  }

  constraint c_default_address {
    solve packet_type before address;
    if (packet_type[7]) {
      address == 0;
    }
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
    get_header_flits(flits);
    get_payload_flits(flits);
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
    unpack_header_flits(flits);

    if (!has_payload()) begin
      return;
    end

    unpack_payload_flits(flits);
  endfunction

  function void unpack_flit_items(const ref noc_bfm_flit_item flit_items[$]);
    noc_bfm_flit  flits[$];
    foreach (flit_items[i]) begin
      flits.push_back(flit_items[i].get_flit());
    end
    unpack_flits(flits);
  endfunction

  local function void get_header_flits(ref noc_bfm_flit flits[$]);
    uvm_packer  packer;
    int         header_width;

    packer  = get_flit_packer();
    packer.pack_field_int(packet_type        , 8                         );
    packer.pack_field_int(destination_id.y   , configuration.id_y_width  );
    packer.pack_field_int(destination_id.x   , configuration.id_x_width  );
    packer.pack_field_int(source_id.y        , configuration.id_y_width  );
    packer.pack_field_int(source_id.x        , configuration.id_x_width  );
    packer.pack_field_int(virtual_channel    , configuration.vc_width    );
    packer.pack_field_int(tag                , configuration.tag_width   );
    packer.pack_field_int(length             , configuration.length_width);
    packer.pack_field_int(invalid_destination, 1                         );
    if (is_request()) begin
      packer.pack_field_int(address, configuration.address_width);
      header_width  = configuration.get_request_header_width();
    end
    else begin
      packer.pack_field_int(status       , 2                                );
      packer.pack_field_int(lower_address, configuration.lower_address_width);
      packer.pack_field_int(last_response, 1                                );
      header_width  = configuration.get_response_header_width();
    end
    packer.set_packed_size();

    while (header_width > 0) begin
      int           unpack_size;
      noc_bfm_flit  flit;

      if (header_width > configuration.get_flit_width()) begin
        unpack_size = configuration.get_flit_width();
      end
      else begin
        unpack_size = header_width;
      end

      flit.flit_type  = NOC_BFM_HEADER_FLIT;
      flit.data       = packer.unpack_field(unpack_size);
      flits.push_back(flit);

      header_width  -= unpack_size;
    end

    flits[0].head = 1;
    if (!packet_type[6]) begin
      flits[$].tail = 1;
    end
  endfunction

  local function void unpack_header_flits(const ref noc_bfm_flit flits[$]);
    uvm_packer    packer  = get_flit_packer();

    foreach (flits[i]) begin
      if (flits[i].flit_type == NOC_BFM_PAYLOAD_FLIT) begin
        break;
      end
      packer.pack_field(flits[i].data, configuration.get_flit_width());
    end
    packer.set_packed_size();

    packet_type         = noc_bfm_packet_type'(packer.unpack_field_int(8));
    destination_id.y    = packer.unpack_field_int(configuration.id_y_width);
    destination_id.x    = packer.unpack_field_int(configuration.id_x_width);
    source_id.y         = packer.unpack_field_int(configuration.id_y_width);
    source_id.x         = packer.unpack_field_int(configuration.id_x_width);
    virtual_channel     = packer.unpack_field_int(configuration.vc_width);
    tag                 = packer.unpack_field_int(configuration.tag_width);
    length              = packer.unpack_field_int(configuration.length_width);
    invalid_destination = packer.unpack_field_int(1);
    if (is_request()) begin
      address = packer.unpack_field_int(configuration.address_width);
    end
    else begin
      status  = noc_bfm_response_status'(packer.unpack_field_int($bits(noc_bfm_response_status)));
      lower_address = packer.unpack_field_int(configuration.lower_address_width);
      last_response = packer.unpack_field_int(1);
    end
  endfunction

  local function void get_payload_flits(ref noc_bfm_flit flits[$]);
    foreach (data[i]) begin
      uvm_packer    packer;
      noc_bfm_flit  flit;

      packer  = get_flit_packer();
      packer.pack_field(data[i], configuration.data_width);
      if (is_request()) begin
        packer.pack_field_int(byte_enable[i], configuration.byte_enable_width);
      end
      else begin
        packer.pack_field_int('0, configuration.byte_enable_width);
      end
      packer.set_packed_size();

      flit.flit_type  = NOC_BFM_PAYLOAD_FLIT;
      flit.data       = packer.unpack_field(configuration.get_payload_width());
      flits.push_back(flit);
    end

    flits[$].tail = 1;
  endfunction

  local function void unpack_payload_flits(const ref noc_bfm_flit flits[$]);
    int offset;

    foreach (flits[i]) begin
      if (flits[i].flit_type == NOC_BFM_PAYLOAD_FLIT) begin
        offset  = i;
        break;
      end
    end

    data  = new[length];
    if (is_request()) begin
      byte_enable = new[length];
    end

    foreach (data[i]) begin
      uvm_packer  packer;

      packer  = get_flit_packer();
      packer.pack_field(flits[i+offset], configuration.get_payload_width());
      packer.set_packed_size();

      data[i] = packer.unpack_field(configuration.data_width);
      if (is_request()) begin
        byte_enable[i]  = packer.unpack_field_int(configuration.byte_enable_width);
      end
    end
  endfunction

  local function uvm_packer get_flit_packer();
    if (flit_packer == null) begin
      flit_packer             = new();
      flit_packer.big_endian  = 0;
    end
    flit_packer.reset();
    return flit_packer;
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
