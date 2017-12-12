#ifndef NOC_INPUT_FIFO_HPP_
#define NOC_INPUT_FIFO_HPP_

#include <systemc>
#include <string>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_flit_fifo.hpp"

namespace noc {

class noc_input_fifo :
    public sc_core::sc_module,
    public noc_flit_if
{
public:
  noc_flit_export flit_in_port;
  noc_flit_port   flit_out_port;

  noc_input_fifo(const sc_core::sc_module_name& name, int fifo_depth);

  ~noc_input_fifo();

  void put(noc_flit& flit);

private:
  typedef enum {
    RESPONSE_CHANNEL,
    REQUEST_CHANNEL
  } channel_type;

  struct channel_status {
    channel_type  current_channel;
    bool          busy;
  };

  SC_HAS_PROCESS(noc_input_fifo);

  noc_flit_fifo*  response_fifo;
  noc_flit_fifo*  request_fifo;

  channel_status  input_channel_status;
  channel_status  output_channel_status;

  void main_thread();
  void arbitrate_output_channel();
};

}  // namespace noc


#endif /* NOC_INPUT_FIFO_HPP_ */
