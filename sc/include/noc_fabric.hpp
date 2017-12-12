/*
 * noc_fabric.hpp
 *
 *  Created on: 2017/12/12
 *      Author: ishitani
 */

#ifndef NOC_FABRIC_HPP_
#define NOC_FABRIC_HPP_

#include <systemc>
#include "noc_flit.hpp"
#include "noc_flit_if.hpp"
#include "noc_router.hpp"
#include "noc_terminator.hpp"

namespace noc {

class noc_fabric :
  public sc_core::sc_module
{
public:
  sc_core::sc_vector<noc_flit_export> flit_in_port;
  sc_core::sc_vector<noc_flit_port>   flit_out_port;

  noc_fabric(const sc_core::sc_module_name& name, int size_x, int size_y, int fifo_depth);

  ~noc_fabric();

private:
  int size_x;
  int size_y;
  int fifo_depth;

  noc_router**      router;
  noc_terminator**  terminator;

  void create_router();
  void create_terminator();
  void connect_router();
};

}  // namespace noc

#endif /* NOC_FABRIC_HPP_ */
