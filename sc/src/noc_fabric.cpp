#include <sstream>
#include "noc_fabric.hpp"

namespace noc {

noc_fabric::noc_fabric(const sc_core::sc_module_name& name, int size_x, int size_y, int fifo_depth) :
    sc_module(name),
    flit_in_port("flit_in_port", size_x * size_y),
    flit_out_port("flit_out_port", size_x * size_y),
    size_x(size_x),
    size_y(size_y),
    fifo_depth(fifo_depth)
{
  create_router();
  create_terminator();
  connect_router();
}

noc_fabric::~noc_fabric() {
  for (int i = 0;i < size_x * size_y;++i) {
    delete (router + i);
  }
  delete[] router;

  for (int i = 0;i < 2 * (size_x + size_y);++i) {
    delete (terminator + i);
  }
  delete[] terminator;
}

void noc_fabric::create_router() {
  router  = new noc_router*[size_x * size_y];
  for (int i = 0;i < size_x * size_y;++i) {
    int                 x;
    int                 y;
    std::ostringstream  ss;
    x = i % size_x;
    y = i / size_y;
    ss << "router" << "[" << i << "]";
    router[i] = new noc_router(ss.str().c_str(), x, y, fifo_depth);
  }
}

void noc_fabric::create_terminator() {
  terminator  = new noc_terminator*[2 * (size_x + size_y)];
  for (int i = 0;i < 2 * (size_x + size_y);++i) {
    std::ostringstream  ss;
    ss << "terminator" << "[" << i << "]";
    terminator[i] = new noc_terminator(ss.str().c_str());
  }
}

void noc_fabric::connect_router() {
  for (int i = 0;i < size_x * size_y;++i) {
    int x = i % size_x;
    int y = i / size_x;

    if (y == 0) {
      router[i]->flit_out_port_y_minus(terminator[x]->flit_in_port);
      terminator[x]->flit_out_port(router[i]->flit_in_port_y_minus);
    }
    if (y > 0) {
      router[i]->flit_out_port_y_minus(router[i-size_x]->flit_in_port_y_plus);
      router[i-size_x]->flit_out_port_y_plus(router[i]->flit_in_port_y_minus);
    }
    if (y == (size_y - 1)) {
      router[i]->flit_out_port_y_plus(terminator[2*size_y+size_x+x]->flit_in_port);
      terminator[2*size_y+size_x+x]->flit_out_port(router[i]->flit_in_port_y_plus);
    }

    if (x == 0) {
      router[i]->flit_out_port_x_minus(terminator[size_x+2*y]->flit_in_port);
      terminator[size_x+2*y]->flit_out_port(router[i]->flit_in_port_x_minus);
    }
    if (x > 0) {
      router[i]->flit_out_port_x_minus(router[i-1]->flit_in_port_x_plus);
      router[i-1]->flit_out_port_x_plus(router[i]->flit_in_port_x_minus);
    }
    if (x == (size_x - 1)) {
      router[i]->flit_out_port_x_plus(terminator[size_x+2*y+1]->flit_in_port);
      terminator[size_x+2*y+1]->flit_out_port(router[i]->flit_out_port_x_plus);
    }

    flit_in_port[i](router[i]->flit_in_port_local);
    router[i]->flit_out_port_local(flit_out_port[i]);
  }
}

}

