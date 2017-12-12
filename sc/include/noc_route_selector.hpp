#ifndef NOC_ROUTE_SELECTOR_HPP_
#define NOC_ROUTE_SELECTOR_HPP_

#include <systemc>
#include <string>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_flit_fifo.hpp"

namespace noc {

class noc_route_selector :
  public sc_core::sc_module
{
public:
  noc_flit_export flit_in_port;
  noc_flit_port   flit_out_port[5];

  noc_route_selector(const sc_core::sc_module_name& name, std::uint32_t x, std::uint32_t y);

  ~noc_route_selector();

private:
  enum port_type {
    PORT_X_PLUS   = 0,
    PORT_X_MINUS  = 1,
    PORT_Y_PLUS   = 2,
    PORT_Y_MINUS  = 3,
    PORT_LOCAL    = 4
  };

  SC_HAS_PROCESS(noc_route_selector);

  std::uint32_t x;
  std::uint32_t y;
  bool          busy;
  port_type     current_port;

  noc_flit_fifo*  input_fifo;

  void main_thread();
  void select_port(const noc_flit& flit);
};

}  // namespace noc

#endif /* NOC_ROUTER_HPP_ */
