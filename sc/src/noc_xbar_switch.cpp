#include "noc_xbar_switch.hpp"

namespace noc {

noc_xbar_switch::noc_xbar_switch(const sc_core::sc_module_name& name) :
    sc_module(name),
    current_port(4),
    busy(false)
{
  for(int i = 0;i < 5;++i) {
    input_fifo[i] = new noc_flit_fifo(1);
    flit_in_port[i](*input_fifo[i]);
  }

  SC_THREAD(main_thread)
}

noc_xbar_switch::~noc_xbar_switch() {
  for (int i = 0;i < 5;++i) {
    delete input_fifo[i];
  }
}

void noc_xbar_switch::main_thread() {
  noc_flit  flit;

  while (true) {
    if (!busy) {
      if (
          (input_fifo[0]->num_available() == 0) &&
          (input_fifo[1]->num_available() == 0) &&
          (input_fifo[2]->num_available() == 0) &&
          (input_fifo[3]->num_available() == 0) &&
          (input_fifo[4]->num_available() == 0)
      ) {
        wait(
            input_fifo[0]->data_written_event() |
            input_fifo[1]->data_written_event() |
            input_fifo[2]->data_written_event() |
            input_fifo[3]->data_written_event() |
            input_fifo[4]->data_written_event()
        );
      }

      abitrate_input_ports();
      busy  = true;
    }

    input_fifo[current_port]->read(flit);
    flit_out_port->put(flit);

    if (flit.is_tail()) {
      busy  = false;
    }
  }
}

void noc_xbar_switch::abitrate_input_ports() {
  switch (current_port) {
    case 0:
      current_port  = (input_fifo[1]->num_available() > 0) ? 1
                    : (input_fifo[2]->num_available() > 0) ? 2
                    : (input_fifo[3]->num_available() > 0) ? 3
                    : (input_fifo[4]->num_available() > 0) ? 4 : 0;
      break;
    case 1:
      current_port  = (input_fifo[2]->num_available() > 0) ? 2
                    : (input_fifo[3]->num_available() > 0) ? 3
                    : (input_fifo[4]->num_available() > 0) ? 4
                    : (input_fifo[0]->num_available() > 0) ? 0 : 1;
      break;
    case 2:
      current_port  = (input_fifo[3]->num_available() > 0) ? 3
                    : (input_fifo[4]->num_available() > 0) ? 4
                    : (input_fifo[0]->num_available() > 0) ? 0
                    : (input_fifo[1]->num_available() > 0) ? 1 : 2;
      break;
    case 3:
      current_port  = (input_fifo[4]->num_available() > 0) ? 4
                    : (input_fifo[0]->num_available() > 0) ? 0
                    : (input_fifo[1]->num_available() > 0) ? 1
                    : (input_fifo[2]->num_available() > 0) ? 2 : 3;
      break;
    case 4:
      current_port  = (input_fifo[0]->num_available() > 0) ? 0
                    : (input_fifo[1]->num_available() > 0) ? 1
                    : (input_fifo[2]->num_available() > 0) ? 2
                    : (input_fifo[3]->num_available() > 0) ? 3 : 4;
      break;
    default:
      break;
  }
}

}
