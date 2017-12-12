#ifndef NOC_ROUTER_HPP_
#define NOC_ROUTER_HPP_

#include <systemc>
#include <cstdint>
#include <string>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_input_fifo.hpp"
#include "noc_route_selector.hpp"
#include "noc_xbar_switch.hpp"

namespace noc {

class noc_router :
    public sc_core::sc_module
{
public:
  noc_flit_export flit_in_port_x_plus;
  noc_flit_port   flit_out_port_x_plus;

  noc_flit_export flit_in_port_x_minus;
  noc_flit_port   flit_out_port_x_minus;

  noc_flit_export flit_in_port_y_plus;
  noc_flit_port   flit_out_port_y_plus;

  noc_flit_export flit_in_port_y_minus;
  noc_flit_port   flit_out_port_y_minus;

  noc_flit_export flit_in_port_local;
  noc_flit_port   flit_out_port_local;

  noc_router(const sc_core::sc_module_name& name, std::uint32_t x, std::uint32_t y, std::uint32_t fifo_depth);

  ~noc_router();

private:
  noc_input_fifo*     input_fifo[5];
  noc_route_selector* route_selector[5];
  noc_xbar_switch*    xbar_switch[5];

  noc_flit_export& flit_in_port(int index);
  noc_flit_port& flit_out_port(int index);
};

}  // namespace noc


#endif /* NOC_ROUNTER_HPP_ */
