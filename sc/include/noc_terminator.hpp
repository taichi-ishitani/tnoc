#ifndef NOC_TERMINATOR_HPP_
#define NOC_TERMINATOR_HPP_

#include <systemc>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_flit_fifo.hpp"

namespace noc {

class noc_terminator :
  public sc_core::sc_module
{
public:
  noc_flit_export flit_in_port;
  noc_flit_port   flit_out_port;

  noc_terminator(const sc_core::sc_module_name& name);

  ~noc_terminator();

private:
  SC_HAS_PROCESS(noc_terminator);

  noc_flit_fifo*  input_fifo;

  void main_thread();
};

}  // namespace noc

#endif /* NOC_TERMINATOR_HPP_ */
