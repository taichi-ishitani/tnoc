#include <systemc>
#include "noc.hpp"

#include <iostream>
#include <list>
#include <sstream>

using namespace sc_core;
using namespace noc;
using namespace std;

class producer :
  public sc_module
{
public:
  noc_flit_port flit_out_port;

  SC_HAS_PROCESS(producer);

  producer(const sc_module_name& name, int x, int y) :
    sc_module(name),
    x(x),
    y(y)
  {
    SC_THREAD(main_thread)
  }

private:
  int x;
  int y;

  void main_thread() {
    list<noc_flit>  flit_list;
    noc_packet      packet;

    packet.header.type              = NOC_READ;
    packet.header.source_id.x       = x;
    packet.header.source_id.y       = y;

    for (int i = 0;i < 4;++i) {
      for (int j = 0;j < 4;++j) {
        packet.header.destination_id.x  = i;
        packet.header.destination_id.y  = j;
        packet.to_flits(flit_list);
      }
    }

    for (list<noc_flit>::iterator i = flit_list.begin();i != flit_list.end();++i) {
      flit_out_port->put(*i);
      wait(1, SC_NS);
    }
  }
};

class consumer :
  public sc_module,
  public noc_flit_if
{
public:
  noc_flit_export flit_in_port;

  SC_HAS_PROCESS(consumer);

  consumer(const sc_module_name& name) :
    sc_module(name)
  {
    flit_in_port(*this);
  }

  void put(noc_flit& flit) {
    cout << name() << endl;
    cout << flit   << endl;
    wait(1, SC_NS);
  }
};

int sc_main(int argc, char** argv) {
  noc_fabric*         fabric;
  producer*           prod[4][4];
  consumer*           cons[4][4];

  fabric  = new noc_fabric("fabric", 4, 4, 2);

  for (int y = 0;y < 4;++y) {
    for (int x = 0;x < 4;++x) {
      ostringstream ssp;
      ostringstream ssc;

      ssp << "prod" << "[" << y << "]" << "[" << x << "]";
      prod[y][x]  = new producer(ssp.str().c_str(), x, y);

      ssc << "cons" << "[" << y << "]" << "[" << x << "]";
      cons[y][x]  = new consumer(ssc.str().c_str());

      prod[y][x]->flit_out_port(fabric->flit_in_port[4*y+x]);
      fabric->flit_out_port[4*y+x](cons[y][x]->flit_in_port);
    }
  }

  sc_start(20, SC_NS);

  return 0;
}
