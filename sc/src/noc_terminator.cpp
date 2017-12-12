#include "noc_terminator.hpp"

namespace noc {

noc_terminator::noc_terminator(const sc_core::sc_module_name& name) :
    sc_module(name)
{
  input_fifo  = new noc_flit_fifo(1);
  flit_in_port(*input_fifo);
  SC_THREAD(main_thread)
}

noc_terminator::~noc_terminator() {
  delete input_fifo;
}

void noc_terminator::main_thread() {
  while (true) {
    noc_flit  flit;
    input_fifo->read(flit);
  }
}

}
