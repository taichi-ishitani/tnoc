#include "noc_router.hpp"
#include <sstream>

namespace noc {

noc_router::noc_router(const sc_core::sc_module_name& name, std::uint32_t x, std::uint32_t y, std::uint32_t fifo_depth) :
    sc_module(name)
{
  for (int i = 0;i < 5;++i) {
    std::ostringstream  ss;
    ss << "input_fifo" << '[' << i << "]";
    input_fifo[i] = new noc_input_fifo(ss.str().c_str(), fifo_depth);
  }
  for (int i = 0;i < 5;++i) {
    std::ostringstream  ss;
    ss << "route_selector" << "[" << i << "]";
    route_selector[i] = new noc_route_selector(ss.str().c_str(), x, y);
  }
  for (int i = 0;i < 5;i++) {
    std::ostringstream  ss;
    ss << "xbar_switch" << "[" << i << "]";
    xbar_switch[i]  = new noc_xbar_switch(ss.str().c_str());
  }
  for (int i = 0;i < 5;++i) {
    flit_in_port(i)(input_fifo[i]->flit_in_port);
    input_fifo[i]->flit_out_port(route_selector[i]->flit_in_port);
    for (int j = 0;j < 5;++j) {
      route_selector[i]->flit_out_port[j](xbar_switch[j]->flit_in_port[i]);
    }
  }
  for (int i = 0;i < 5;++i) {
    xbar_switch[i]->flit_out_port(flit_out_port(i));
  }
}

noc_router::~noc_router() {
  for (int i = 0;i < 5;++i) {
    delete input_fifo[i];
    delete route_selector[i];
    delete xbar_switch[i];
  }
}

noc_flit_export& noc_router::flit_in_port(int index) {
  switch (index) {
    case 0:   return flit_in_port_x_plus;
    case 1:   return flit_in_port_x_minus;
    case 2:   return flit_in_port_y_plus;
    case 3:   return flit_in_port_y_minus;
    default:  return flit_in_port_local;
  }
}

noc_flit_port& noc_router::flit_out_port(int index) {
  switch (index) {
    case 0:   return flit_out_port_x_plus;
    case 1:   return flit_out_port_x_minus;
    case 2:   return flit_out_port_y_plus;
    case 3:   return flit_out_port_y_minus;
    default:  return flit_out_port_local;
  }
}

}
