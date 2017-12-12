#ifndef NOC_FLIT_IF_HPP_
#define NOC_FLIT_IF_HPP_

#include <systemc>
#include "noc_flit.hpp"

namespace noc {

class noc_flit_if :
  public sc_core::sc_interface
{
public:
  virtual void put(noc_flit& flit) = 0;
};

typedef sc_core::sc_port<noc_flit_if>   noc_flit_port;
typedef sc_core::sc_export<noc_flit_if> noc_flit_export;

}  // namespace noc

#endif /* NOC_FLIT_IF_HPP_ */
