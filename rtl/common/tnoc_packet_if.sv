`ifndef TNOC_PACKET_IF_SV
`define TNOC_PACKET_IF_SV
interface tnoc_packet_if
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)();
  `include  "tnoc_packet.svh"

  //  Header
  logic                       header_valid;
  logic                       header_ready;
  tnoc_packet_type            packet_type;
  tnoc_location_id            destination_id;
  tnoc_location_id            source_id;
  tnoc_vc                     vc;
  tnoc_tag                    tag;
  tnoc_routing_mode           routing_mode;
  logic                       invalid_destination;
  tnoc_burst_type             burst_type;
  tnoc_unpacked_burst_length  burst_length;
  tnoc_burst_size             burst_size;
  tnoc_address                address;
  tnoc_response_status        packet_status;
  //  Payload
  logic                       payload_valid;
  logic                       payload_ready;
  tnoc_payload_type           payload_type;
  logic                       payload_last;
  tnoc_data                   data;
  tnoc_byte_enable            byte_enable;
  tnoc_response_status        payload_status;
  logic                       response_last;

  modport initiator (
    output  header_valid,
    input   header_ready,
    output  packet_type,
    output  destination_id,
    output  source_id,
    output  vc,
    output  tag,
    output  routing_mode,
    output  invalid_destination,
    output  burst_type,
    output  burst_length,
    output  burst_size,
    output  address,
    output  packet_status,
    output  payload_valid,
    input   payload_ready,
    output  payload_type,
    output  payload_last,
    output  data,
    output  byte_enable,
    output  payload_status,
    output  response_last
  );

  modport target (
    input   header_valid,
    output  header_ready,
    input   packet_type,
    input   destination_id,
    input   source_id,
    input   vc,
    input   tag,
    input   routing_mode,
    input   invalid_destination,
    input   burst_type,
    input   burst_length,
    input   burst_size,
    input   address,
    input   packet_status,
    input   payload_valid,
    output  payload_ready,
    input   payload_type,
    input   payload_last,
    input   data,
    input   byte_enable,
    input   payload_status,
    input   response_last
  );

  modport monitor (
    input header_valid,
    input header_ready,
    input packet_type,
    input destination_id,
    input source_id,
    input vc,
    input tag,
    input routing_mode,
    input invalid_destination,
    input burst_type,
    input burst_length,
    input burst_size,
    input address,
    input packet_status,
    input payload_valid,
    input payload_ready,
    input payload_type,
    input payload_last,
    input data,
    input byte_enable,
    input payload_status,
    input response_last
  );
endinterface
`endif
