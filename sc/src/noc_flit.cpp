#include <iomanip>
#include "noc_flit.hpp"

namespace noc {
std::ostream& operator<<(std::ostream& os, const noc_flit_type& type) {
  switch (type) {
    case NOC_HEADER_FLIT:
      os << "header flit";
      break;
    case NOC_PAYLOAD_FLIT:
      os << "payload flit";
      break;
  }
  return os;
}

noc_flit::noc_flit() :
    type(NOC_HEADER_FLIT),
    tail(false),
    header(),
    payload()
{}

noc_flit::noc_flit(const noc_packet_header& header, bool tail) :
    type(NOC_HEADER_FLIT),
    tail(tail),
    header(header),
    payload()
{}

noc_flit::noc_flit(const noc_packet_payload& payload, bool tail) :
    type(NOC_PAYLOAD_FLIT),
    tail(tail),
    header(),
    payload(payload)
{}

bool noc_flit::is_header() const {
  return (type == NOC_HEADER_FLIT) ? true : false;
}

bool noc_flit::is_payload() const {
  return (type == NOC_PAYLOAD_FLIT) ? true : false;
}

bool noc_flit::is_tail() const {
  return tail;
}

std::ostream& operator<<(std::ostream& os, const noc_flit& flit) {
  os << "flit type: "
     << flit.type
     << std::endl;
  os << "tail: "
     << std::boolalpha
     << flit.tail
     << std::endl;
  if (flit.is_header()) {
    os << "-- header --" << std::endl;
    os << flit.header;
  }
  else {
    os << "-- payload --" << std::endl;
    os << flit.payload;
  }
  return os;
}

}
