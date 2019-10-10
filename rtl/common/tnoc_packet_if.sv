`ifndef TNOC_PACKET_IF_SV
`define TNOC_PACKET_IF_SV
interface tnoc_packet_if
  import  tnoc_pkg::*;
#(
  parameter tnoc_packet_config  PACKET_CONFIG = TNOC_DEFAULT_PACKET_CONFIG
)(
  tnoc_types  types
);
//--------------------------------------------------------------
//  Variable declarations
//--------------------------------------------------------------
  typedef types.tnoc_header_fields  tnoc_header_fields;
  typedef types.tnoc_payload_fields tnoc_payload_fields;

  logic               header_valid;
  logic               header_ready;
  tnoc_header_fields  header;
  logic               payload_valid;
  logic               payload_ready;
  logic               payload_last;
  tnoc_payload_fields payload;

//--------------------------------------------------------------
//  API
//--------------------------------------------------------------
  function automatic logic get_header_ack();
    return header_valid & header_ready;
  endfunction

  function automatic logic get_payload_ack();
    return payload_valid & payload_ready;
  endfunction

  typedef types.tnoc_burst_length           tnoc_burst_length;
  typedef types.tnoc_packed_burst_length    tnoc_packed_burst_length;
  typedef types.tnoc_common_header_fields   tnoc_common_header_fields;
  typedef types.tnoc_request_header_fields  tnoc_request_header_fields;
  typedef types.tnoc_response_header_fields tnoc_response_header_fields;
  typedef types.tnoc_common_header          tnoc_common_header;
  typedef types.tnoc_request_header         tnoc_request_header;
  typedef types.tnoc_response_header        tnoc_response_header;
  //typedef types.tnoc_packed_header          tnoc_packed_header;
  typedef logic [get_header_width(PACKET_CONFIG)-1:0]   tnoc_packed_header;

  function automatic tnoc_packed_header pack_header();
    tnoc_common_header_fields   common_fields;

    common_fields = '{
      packet_type:          header.packet_type,
      destination_id:       header.destination_id,
      source_id:            header.source_id,
      vc:                   header.vc,
      tag:                  header.tag,
      invalid_destination:  header.invalid_destination
    };

    //if (is_request_packet_type(header.packet_type)) begin
    if (!header.packet_type[7]) begin
      tnoc_packed_burst_length    packed_burst_length;
      tnoc_request_header         request_header;
      tnoc_request_header_fields  request_fields;

      packed_burst_length = header.burst_length;
      request_fields      = '{
        burst_type:   header.burst_type,
        burst_length: packed_burst_length,
        burst_size:   header.burst_size,
        address:      header.address
      };

      request_header.common   = common_fields;
      request_header.request  = request_fields;
      return request_header;
    end
    else begin
      tnoc_response_header_fields response_fields;
      tnoc_response_header        response_header;

      response_fields = '{
        status: header.status
      };

      response_header.common    = common_fields;
      response_header.response  = response_fields;
      return response_header;
    end
  endfunction

  function automatic void unpack_header(tnoc_packed_header packed_header);
    tnoc_burst_length     burst_length;
    tnoc_common_header    common_header;
    tnoc_request_header   request_header;
    tnoc_response_header  response_header;

    common_header   = packed_header;
    request_header  = packed_header;
    response_header = packed_header;

    if (request_header.request.burst_length == 0) begin
      burst_length  = PACKET_CONFIG.max_burst_length;
    end
    else begin
      burst_length  = request_header.request.burst_length;
    end

    header  = '{
      packet_type:          common_header.packet_type,
      destination_id:       common_header.destination_id,
      source_id:            common_header.source_id,
      vc:                   common_header.vc,
      tag:                  common_header.tag,
      invalid_destination:  common_header.invalid_destination,
      burst_type:           request_header.request.burst_type,
      burst_length:         burst_length,
      burst_size:           request_header.request.burst_size,
      address:              request_header.request.address,
      status:               response_header.response.status
    };
  endfunction

  typedef types.tnoc_request_payload    tnoc_request_payload;
  typedef types.tnoc_response_payload   tnoc_response_payload;
  //typedef types.tnoc_packed_payload     tnoc_packed_payload;
  typedef logic [get_payload_width(PACKET_CONFIG)-1:0]  tnoc_packed_payload;

  function automatic tnoc_packed_payload pack_payload(tnoc_packet_type packet_type);
    //if (is_request_packet_type(packet_type)) begin
    if (!packet_type[7]) begin
      tnoc_request_payload  request_payload;
      request_payload = '{
        data:         payload.data,
        byte_enable:  payload.byte_enable
      };
      return request_payload;
    end
    else begin
      tnoc_response_payload response_payload;
      response_payload  = '{
        data:   payload.data,
        status: payload.status,
        last:   payload.last
      };
      return response_payload;
    end
  endfunction

  function automatic void unpack_payload(tnoc_packed_payload packed_payload);
    tnoc_request_payload  request_payload;
    tnoc_response_payload response_payload;

    request_payload   = packed_payload;
    response_payload  = packed_payload;

    payload = '{
      data:         request_payload.data,
      byte_enable:  request_payload.byte_enable,
      status:       response_payload.status,
      last:         response_payload.last
    };
  endfunction

//--------------------------------------------------------------
//  Modport
//--------------------------------------------------------------
  modport master (
    output  header_valid,
    input   header_ready,
    output  header,
    output  payload_valid,
    input   payload_ready,
    output  payload_last,
    output  payload,
    import  get_header_ack,
    import  get_payload_ack,
    import  unpack_header,
    import  unpack_payload
  );

  modport slave (
    input   header_valid,
    output  header_ready,
    input   header,
    input   payload_valid,
    output  payload_ready,
    input   payload_last,
    input   payload,
    import  get_header_ack,
    import  get_payload_ack,
    import  pack_header,
    import  pack_payload
  );

  modport monitor (
    input   header_valid,
    input   header_ready,
    input   header,
    input   payload_valid,
    input   payload_ready,
    input   payload_last,
    import  get_header_ack,
    import  get_payload_ack
  );
endinterface
`endif
