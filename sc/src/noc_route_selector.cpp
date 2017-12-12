#include "noc_route_selector.hpp"

namespace noc {

noc_route_selector::noc_route_selector(const sc_core::sc_module_name& name, std::uint32_t x, std::uint32_t y) :
    sc_module(name),
    x(x),
    y(y),
    busy(false),
    current_port(PORT_X_PLUS)
{
  input_fifo  = new noc_flit_fifo(1);
  flit_in_port(*input_fifo);
  SC_THREAD(main_thread)
}

noc_route_selector::~noc_route_selector() {
  delete input_fifo;
}

void noc_route_selector::main_thread() {
  while (true) {
    noc_flit  flit  = input_fifo->read();

    if (!busy) {
      select_port(flit);
      busy  = true;
    }

    flit_out_port[current_port]->put(flit);

    if (flit.is_tail()) {
      busy  = false;
    }
  }
}

void noc_route_selector::select_port(const noc_flit& flit) {
  noc_location_id destination_id  = flit.header.destination_id;
  if (destination_id.x != x) {
    if (destination_id.x > x) {
      current_port  = PORT_X_PLUS;
    }
    else {
      current_port  = PORT_X_MINUS;
    }
  }
  else if (destination_id.y != y) {
    if (destination_id.y > y) {
      current_port  = PORT_Y_PLUS;
    }
    else {
      current_port  = PORT_Y_MINUS;
    }
  }
  else {
    current_port  = PORT_LOCAL;
  }
}

}
