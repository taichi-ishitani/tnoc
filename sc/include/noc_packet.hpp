#ifndef NOC_PACKET_HPP_
#define NOC_PACKET_HPP_

#include <systemc>
#include <cinttypes>
#include <string>
#include <ostream>
#include <list>

namespace noc {

class noc_flit;

struct noc_location_id {
  std::uint32_t x;
  std::uint32_t y;

  noc_location_id();
};

std::ostream& operator<<(std::ostream& os, const noc_location_id& id);

enum noc_packet_type {
  NOC_POSTED_WRITE,
  NOC_NON_POSTED_WRITE,
  NOC_READ,
  NOC_RESPONSE,
  NOC_RESPONSE_WITH_DATA
};

std::ostream& operator<<(std::ostream& os, const noc_packet_type& type);

enum noc_response_status {
  NOC_OKAY,
  NOC_EXOKAY,
  NOC_SLAVE_ERROR,
  NOC_DECODE_ERROR
};

std::ostream& operator<<(std::ostream& os, const noc_response_status status);

struct noc_request_packet_header {
  std::uint64_t address;

  noc_request_packet_header();
};

std::ostream& operator<<(std::ostream& os, const noc_request_packet_header& header);

struct noc_response_packet_header {
  noc_response_status status;
  std::uint32_t       lower_address;
  bool                last_response;

  noc_response_packet_header();
};

std::ostream& operator<<(std::ostream& os, const noc_response_packet_header& header);

struct noc_packet_header {
  noc_packet_type             type;
  noc_location_id             destination_id;
  noc_location_id             source_id;
  std::uint32_t               tag;
  std::uint32_t               length;
  noc_request_packet_header   request;
  noc_response_packet_header  response;

  noc_packet_header();

  bool is_request() const;
  bool is_response() const;
};

std::ostream& operator<<(std::ostream& os, const noc_packet_header& header);

const int NOC_PACKET_DATA_WIDTH = 256;

typedef sc_dt::sc_biguint<NOC_PACKET_DATA_WIDTH>  noc_packet_data;
typedef sc_dt::sc_uint<NOC_PACKET_DATA_WIDTH/8>   noc_packet_byte_enable;

struct noc_packet_payload {
  noc_packet_data         data;
  noc_packet_byte_enable  byte_enable;

  noc_packet_payload();
};

std::ostream& operator<<(std::ostream& os, const noc_packet_payload& payload);

typedef std::list<noc_packet_payload> noc_packet_payloads;

struct noc_packet {
  noc_packet_header   header;
  noc_packet_payloads payloads;

  noc_packet();

  bool has_header_only() const;
  bool has_payloads() const;

  void set_payload(noc_packet_data data, noc_packet_byte_enable byte_enalbe);

  void to_flits(std::list<noc_flit>& flits);
  void from_flits(std::list<noc_flit>& flits);
};

std::ostream& operator<<(std::ostream& os, const noc_packet& packet);

}  // namespace noc

#endif /* NOC_PACKET_HPP_ */
