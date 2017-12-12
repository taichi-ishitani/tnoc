#ifndef NOC_FLIT_FIFO_HPP_
#define NOC_FLIT_FIFO_HPP_

#include <systemc>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"

namespace noc {

class noc_flit_fifo :
    public sc_core::sc_fifo<noc_flit>,
    public noc_flit_if
{
public:
  noc_flit_fifo(int depth);

  void put(noc_flit& flit);
};

}  // namespace noc

#endif /* NOC_FLIT_FIFO_HPP_ */
