#include "noc_input_fifo.hpp"

namespace noc {

noc_input_fifo::noc_input_fifo(const sc_core::sc_module_name& name, int fifo_depth) :
    sc_module(name),
    input_channel_status({REQUEST_CHANNEL, false}),
    output_channel_status({REQUEST_CHANNEL, false})
{
  response_fifo = new noc_flit_fifo(fifo_depth);
  request_fifo  = new noc_flit_fifo(fifo_depth);

  flit_in_port(*this);
  SC_THREAD(main_thread)
}

noc_input_fifo::~noc_input_fifo() {
  delete response_fifo;
  delete request_fifo;
}

void noc_input_fifo::put(noc_flit& flit) {
  if (!input_channel_status.busy) {
    if (flit.header.is_response()) {
      input_channel_status.current_channel  = RESPONSE_CHANNEL;
    }
    else {
      input_channel_status.current_channel  = REQUEST_CHANNEL;
    }
    input_channel_status.busy = true;
  }

  if (input_channel_status.current_channel == RESPONSE_CHANNEL) {
    response_fifo->write(flit);
  }
  else {
    request_fifo->write(flit);
  }

  if (flit.is_tail()) {
    input_channel_status.busy = false;
  }
}

void noc_input_fifo::main_thread() {
  noc_flit  flit;

  while (true) {
    if (!output_channel_status.busy) {
      if ((response_fifo->num_available() == 0) && (request_fifo->num_available() == 0)) {
        wait(
            response_fifo->data_written_event() |
            request_fifo->data_written_event()
        );
      }
      arbitrate_output_channel();
      output_channel_status.busy  = true;
    }

    if (output_channel_status.current_channel == RESPONSE_CHANNEL) {
      response_fifo->read(flit);
    }
    else {
      request_fifo->read(flit);
    }
    flit_out_port->put(flit);

    if (flit.is_tail()) {
      output_channel_status.busy  = false;
    }
  }
}

void noc_input_fifo::arbitrate_output_channel() {
  if ((response_fifo->num_available() > 0) && (request_fifo->num_available() > 0)) {
    if (output_channel_status.current_channel == RESPONSE_CHANNEL) {
      output_channel_status.current_channel = REQUEST_CHANNEL;
    }
    else {
      output_channel_status.current_channel = RESPONSE_CHANNEL;
    }
  }
  else if (response_fifo->num_available() > 0) {
    output_channel_status.current_channel = RESPONSE_CHANNEL;
  }
  else {
    output_channel_status.current_channel = REQUEST_CHANNEL;
  }
}

}
