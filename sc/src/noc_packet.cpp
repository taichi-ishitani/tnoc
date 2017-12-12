#include <iomanip>
#include "noc_packet.hpp"
#include "noc_flit.hpp"

namespace noc {

noc_location_id::noc_location_id() :
    x(0),
    y(0)
{}

std::ostream& operator<<(std::ostream& os, const noc_location_id& id) {
  os << "x: " << id.x << " " << "y: " << id.y;
  return os;
}

std::ostream& operator<<(std::ostream& os, const noc_packet_type& type) {
  switch (type) {
    case NOC_POSTED_WRITE:
      os << "posted write";
      break;
    case NOC_NON_POSTED_WRITE:
      os << "non posted write";
      break;
    case NOC_READ:
      os << "read";
      break;
    case NOC_RESPONSE:
      os << "response";
      break;
    case NOC_RESPONSE_WITH_DATA:
      os << "response with data";
      break;
  }
  return os;
}

std::ostream& operator<<(std::ostream& os, const noc_response_status status) {
  switch (status) {
    case NOC_OKAY:
      os << "okay";
      break;
    case NOC_EXOKAY:
      os << "ex-okay";
      break;
    case NOC_SLAVE_ERROR:
      os << "slave error";
      break;
    case NOC_DECODE_ERROR:
      os << "decode error";
      break;
  }
  return os;
}

noc_request_packet_header::noc_request_packet_header() :
    address(0)
{}

std::ostream& operator<<(std::ostream& os, const noc_request_packet_header& header) {
  os << "address: "
     << std::showbase
     << std::hex
     << std::setw(16)
     << std::setfill('0')
     << header.address;
  return os;
}

noc_response_packet_header::noc_response_packet_header() :
    status(NOC_OKAY),
    lower_address(0),
    last_response(false)
{}

std::ostream& operator<<(std::ostream& os, const noc_response_packet_header& header) {
  os << "status: "
     << header.status
     << std::endl;
  os << "lower address: "
     << std::showbase
     << std::hex
     << std::setw(2)
     << std::setfill('0')
     << header.lower_address
     << std::endl;
  os << "last response: "
     << std::boolalpha
     << header.last_response;
  return os;
}

noc_packet_header::noc_packet_header() :
    type(NOC_POSTED_WRITE),
    destination_id(),
    source_id(),
    tag(0),
    length(0),
    request(),
    response()
{}

bool noc_packet_header::is_request() const {
  return (!is_response()) ? true : false;
}

bool noc_packet_header::is_response() const {
  switch (type) {
    case NOC_RESPONSE:
    case NOC_RESPONSE_WITH_DATA:
      return true;
    default:
      return false;
  }
}

std::ostream& operator<<(std::ostream& os, const noc_packet_header& header) {
  os << "type: "
     << header.type
     << std::endl;
  os << "destination id: "
     << header.destination_id
     << std::endl;
  os << "source id: "
     << header.source_id
     << std::endl;
  os << "tag: "
     << std::dec
     << header.tag
     << std::endl;
  os << "length: "
     << std::dec
     << header.length
     << std::endl;
  if (header.is_request()) {
    os << header.request;
  }
  else {
    os << header.response;
  }
  return os;
}

noc_packet_payload::noc_packet_payload() :
    data(0),
    byte_enable(0)
{}

std::ostream& operator<<(std::ostream& os, const noc_packet_payload& payload) {
  os << "data: "
     << std::showbase
     << std::setw(NOC_PACKET_DATA_WIDTH / 4)
     << std::setfill('0')
     << payload.data
     << std::endl;
  os << "byte enable: "
     << std::showbase
     << std::setw(NOC_PACKET_DATA_WIDTH / 32)
     << std::setfill('0')
     << payload.byte_enable;
  return os;
}

noc_packet::noc_packet() :
    header(),
    payloads()
{}

bool noc_packet::has_header_only() const {
  switch (header.type) {
    case NOC_READ:
    case NOC_RESPONSE:
      return true;
    default:
      return false;
  }
}

bool noc_packet::has_payloads() const {
  return (!has_header_only()) ? true : false;
}

void noc_packet::set_payload(noc_packet_data data, noc_packet_byte_enable byte_enable) {
  noc_packet_payload  payload;
  payload.data        = data;
  payload.byte_enable = byte_enable;
  payloads.push_back(payload);
}

void noc_packet::to_flits(std::list<noc_flit>& flits) {
  {
    noc_flit  header_flit(header, has_header_only());
    flits.push_back(header_flit);
  }

  if (has_header_only()) {
    return;
  }

  for (noc_packet_payloads::iterator i = payloads.begin();i != payloads.end();++i) {
    bool      tail  = (i == (--payloads.end()));
    noc_flit  payload_flit(*i, tail);
    flits.push_back(payload_flit);
  }
}

void noc_packet::from_flits(std::list<noc_flit>& flits) {
  for (std::list<noc_flit>::iterator i = flits.begin();i != flits.end();++i) {
    if (i->is_header()) {
      header  = i->header;
    }
    else {
      payloads.push_back(i->payload);
    }
  }
}

std::ostream& operator<<(std::ostream& os, const noc_packet& packet) {
  os << "-- header --" << std::endl;
  os << packet.header  << std::endl;
  if (packet.has_header_only()) {
    return os;
  }

  os << "-- payloads --" << std::endl;
  for (noc_packet_payloads::const_iterator i = packet.payloads.begin();i != packet.payloads.end();++i) {
    os << *i << std::endl;
  }
  return os;
}

}
