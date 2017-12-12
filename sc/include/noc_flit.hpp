#ifndef NOC_FLIT_HPP_
#define NOC_FLIT_HPP_

#include <systemc>
#include <iostream>
#include <list>
#include "noc_packet.hpp"

namespace noc {

enum noc_flit_type {
  NOC_HEADER_FLIT,
  NOC_PAYLOAD_FLIT
};

std::ostream& operator<<(std::ostream& os, const noc_flit_type& type);

struct noc_flit {
  noc_flit_type       type;
  bool                tail;
  noc_packet_header   header;
  noc_packet_payload  payload;

  noc_flit();
  noc_flit(const noc_packet_header& header, bool tail);
  noc_flit(const noc_packet_payload& payload, bool tail);

  bool is_header() const;
  bool is_payload() const;
  bool is_tail() const;
};

std::ostream& operator<<(std::ostream& os, const noc_flit& flit);

}  // namespace noc
#endif /* NOC_FLIT_HPP_ */
