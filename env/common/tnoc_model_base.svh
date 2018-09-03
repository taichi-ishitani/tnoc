`ifndef TNOC_MODEL_BASE_SVH
`define TNOC_MODEL_BASE_SVH
virtual class tnoc_model_base #(
  type  CONFIGURATION = tue_configuration_dummy,
  type  STATUS        = tue_status_dummy
) extends tue_component #(CONFIGURATION, STATUS);
  typedef tnoc_model_base #(
    CONFIGURATION, STATUS
  ) this_type;

  typedef uvm_analysis_port #(tnoc_bfm_packet_item)
    tue_packet_analysis_port;

  uvm_analysis_imp #(
    tnoc_bfm_packet_item, this_type
  ) packet_export;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet_export = new("packet_export", this);
  endfunction

  function void write(tnoc_bfm_packet_item item);
    tnoc_bfm_packet_item      expected_item;
    tue_packet_analysis_port  port;

    expected_item = create_expected_item(item);
    if (expected_item == null) begin
      return;
    end

    port  = find_port(expected_item);
    if (port == null) begin
      return;
    end
    port.write(expected_item);
  endfunction

  protected virtual function tnoc_bfm_packet_item create_expected_item(
    tnoc_bfm_packet_item  item
  );
    if (is_valid_item(item)) begin
      return item;
    end
    else if (item.is_non_posted_request()) begin
      return create_error_response_item(item);
    end
    else begin
      return null;
    end
  endfunction

  protected virtual function bit is_valid_item(
    tnoc_bfm_packet_item  item
  );
    if (item.invalid_destination) begin
      return 0;
    end
    else if (item.destination_id.x >= configuration.size_x) begin
      return 0;
    end
    else if (item.destination_id.y >= configuration.size_y) begin
      return 0;
    end
    else begin
      return 1;
    end
  endfunction

  protected virtual function tnoc_bfm_packet_item create_error_response_item(
    tnoc_bfm_packet_item  item
  );
    tnoc_bfm_packet_item  response_item;
    response_item                     = tnoc_bfm_packet_item::type_id::create(item.get_name());
    response_item.packet_type         = (item.has_payload() || (item.burst_length == 0)) ? TNOC_BFM_RESPONSE : TNOC_BFM_RESPONSE_WITH_DATA;
    response_item.destination_id      = item.source_id;
    response_item.source_id           = item.destination_id;
    response_item.virtual_channel     = item.virtual_channel;
    response_item.tag                 = item.tag;
    response_item.routing_mode        = item.routing_mode;
    response_item.invalid_destination = 0;
    response_item.packet_status       = TNOC_BFM_DECODE_ERROR;
    if (!item.has_payload()) begin
      response_item.data            = new[item.burst_length];
      response_item.payload_status  = new[item.burst_length];
      foreach (response_item.data[i]) begin
        response_item.data[i]           = configuration.error_data;
        response_item.payload_status[i] = TNOC_BFM_DECODE_ERROR;
      end
    end
    return response_item;
  endfunction

  protected pure virtual function tue_packet_analysis_port find_port(
    tnoc_bfm_packet_item  item
  );

  `tue_component_default_constructor(tnoc_model_base)
endclass
`endif
