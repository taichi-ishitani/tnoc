`ifndef TNOC_BFM_TRANSMIT_PACKET_SEQUENCE_SVH
`define TNOC_BFM_TRANSMIT_PACKET_SEQUENCE_SVH
class tnoc_bfm_transmit_packet_sequence extends tnoc_bfm_sequence_base;
  rand  tnoc_bfm_packet_type      packet_type;
  rand  tnoc_bfm_location_id      destination_id;
  rand  tnoc_bfm_location_id      source_id;
  rand  tnoc_bfm_vc               virtual_channel;
  rand  tnoc_bfm_tag              tag;
  rand  tnoc_bfm_routing_mode     routing_mode;
  rand  bit                       invalid_destination;
  rand  tnoc_bfm_burst_type       burst_type;
  rand  int                       burst_length;
  rand  int                       burst_size;
  rand  tnoc_bfm_address          address;
  rand  tnoc_bfm_response_status  status;
  rand  tnoc_bfm_data             data[];
  rand  tnoc_bfm_byte_enable      byte_enable[];

  constraint c_default_source_id {
    soft source_id.x == configuration.id_x;
    soft source_id.y == configuration.id_y;
  }

  constraint c_valid_virtual_channel {
    solve packet_type before virtual_channel;
    virtual_channel < configuration.virtual_channels;
  }

  constraint c_default_virtual_channel {
    if (packet_type inside {TNOC_BFM_RESPONSE, TNOC_BFM_RESPONSE_WITH_DATA}) {
      soft virtual_channel == 0;
    }
    else {
      soft virtual_channel == 1;
    }
  }

  constraint c_valid_tag {
    tag < 2**configuration.tag_width;
  }

  constraint c_default_invalid_destination {
    soft invalid_destination == 0;
  }

  constraint c_default_burst_type {
    solve packet_type before burst_type;
    if (packet_type[7]) {
      burst_type == TNOC_BFM_FIXED_BURST;
    }
  }

  constraint c_valid_burst_length {
    solve packet_type before burst_length;
    if ((!packet_type[7]) || packet_type[6]) {
      burst_length inside {[1:2**configuration.burst_length_width]};
    }
    else {
      burst_length == 0;
    }
  }

  constraint c_valid_burst_size {
    solve packet_type before burst_size;
    if (!packet_type[7]) {
      burst_size inside {[1:configuration.data_width / 8]};
      $countones(burst_size) == 1;
    }
    else {
      burst_size == 0;
    }
  }

  constraint c_default_address {
    solve packet_type before address;
    if (packet_type[7]) {
      address == 0;
    }
  }

  constraint c_valid_status {
    solve packet_type before status;
    if (!packet_type[7]) {
      status == TNOC_BFM_OKAY;
    }
  }

  constraint c_defualt_status {
    if (packet_type[7]) {
      soft status == TNOC_BFM_OKAY;
    }
  }

  constraint c_valid_data {
    solve packet_type, burst_length before data;
    if (packet_type[6]) {
      data.size == burst_length;
      foreach (data[i]) {
        (data[i] >> configuration.data_width) == 0;
      }
    }
    else {
      data.size == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve packet_type, burst_length before byte_enable;
    if ((!packet_type[7]) && packet_type[6]) {
      byte_enable.size == burst_length;
      foreach (byte_enable[i]) {
        (byte_enable[i] >> configuration.byte_enable_width) == 0;
      }
    }
    else {
      byte_enable.size == 0;
    }
  }

  function void post_randomize();
    if (packet_type inside {TNOC_BFM_RESPONSE, TNOC_BFM_RESPONSE_WITH_DATA}) begin
      burst_length  = 0;
    end
  endfunction

  task body();
    if (p_sequencer.vc_sequencers.exists(virtual_channel)) begin
      tnoc_bfm_packet_item  packet_item;
      `uvm_create_on(packet_item, p_sequencer.vc_sequencers[virtual_channel])
      set_packet_fields(packet_item);
      `uvm_send(packet_item)
    end
  endtask

  function void set_packet_fields(tnoc_bfm_packet_item packet_item);
    packet_item.packet_type         = packet_type;
    packet_item.destination_id      = destination_id;
    packet_item.source_id           = source_id;
    packet_item.virtual_channel     = virtual_channel;
    packet_item.tag                 = tag;
    packet_item.routing_mode        = routing_mode;
    packet_item.invalid_destination = invalid_destination;
    case (packet_type)
      TNOC_BFM_READ,
      TNOC_BFM_POSTED_WRITE,
      TNOC_BFM_NON_POSTED_WRITE: begin
        packet_item.burst_type    = burst_type;
        packet_item.burst_length  = burst_length;
        packet_item.burst_size    = burst_size;
        packet_item.address       = address;
      end
      TNOC_BFM_RESPONSE,
      TNOC_BFM_RESPONSE_WITH_DATA: begin
        packet_item.status  = status;
      end
    endcase
    case (packet_type)
      TNOC_BFM_POSTED_WRITE,
      TNOC_BFM_NON_POSTED_WRITE: begin
        packet_item.data        = new[data.size](data);
        packet_item.byte_enable = new[byte_enable.size](byte_enable);
      end
      TNOC_BFM_RESPONSE_WITH_DATA: begin
        packet_item.data  = new[data.size](data);
      end
    endcase
  endfunction

  `tue_object_default_constructor(tnoc_bfm_transmit_packet_sequence)
  `uvm_object_utils_begin(tnoc_bfm_transmit_packet_sequence)
    `uvm_field_enum(tnoc_bfm_packet_type, packet_type, UVM_DEFAULT)
    `uvm_field_int(destination_id     , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(source_id          , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(virtual_channel    , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tag                , UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(tnoc_bfm_routing_mode   , routing_mode, UVM_DEFAULT)
    `uvm_field_int(invalid_destination, UVM_DEFAULT | UVM_BIN)
    `uvm_field_enum(tnoc_bfm_burst_type     , burst_type  , UVM_DEFAULT)
    `uvm_field_int(burst_length       , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(burst_size         , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address            , UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(tnoc_bfm_response_status, status, UVM_DEFAULT)
    `uvm_field_array_int(data       , UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
`endif
