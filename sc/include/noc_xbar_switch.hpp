#ifndef NOC_XBAR_SWITCH_HPP_
#define NOC_XBAR_SWITCH_HPP_

#include <systemc>
#include <string>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_flit_fifo.hpp"

namespace noc {

class noc_xbar_switch :
  public sc_core::sc_module
{
public:
  noc_flit_export flit_in_port[5];
  noc_flit_port   flit_out_port;

  noc_xbar_switch(const sc_core::sc_module_name& name);

  ~noc_xbar_switch();

private:
  SC_HAS_PROCESS(noc_xbar_switch);

  noc_flit_fifo*  input_fifo[5];

  int   current_port;
  bool  busy;

  void main_thread();
  void abitrate_input_ports();
};

}  // namespace noc

#endif /* NOC_XBAR_SWITCH_HPP_ */
