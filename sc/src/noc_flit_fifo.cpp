/*
 * noc_flit_fifo.cpp
 *
 *  Created on: 2017/12/05
 *      Author: ishitani
 */

#include "noc_flit_fifo.hpp"

namespace noc {
noc_flit_fifo::noc_flit_fifo(int depth) :
    sc_fifo(depth)
{}

void noc_flit_fifo::put(noc_flit& flit) {
  write(flit);
}

}
