`ifndef NOC_FABRIC_ENV_CONFIGURATION_SVH
`define NOC_FABRIC_ENV_CONFIGURATION_SVH
class noc_fabric_env_configuration extends tue_configuration;
        int                   size_x;
        int                   size_y;
  rand  noc_bfm_configuration bfm_cfg[int];

  constraint c_default_id {
    foreach (bfm_cfg[i]) {
      soft bfm_cfg[i].id_x == (i % size_x);
      soft bfm_cfg[i].id_y == (i / size_x);
    }
  }

  function void create_sub_cfgs(
    input int               size_x,
    input int               size_y,
    ref   noc_bfm_flit_vif  tx_vif[int],
    ref   noc_bfm_flit_vif  rx_vif[int]
  );
    this.size_x = size_x;
    this.size_y = size_y;

    for (int i = 0;i < size_x * size_y;++i) begin
      int x = i % size_x;
      int y = i / size_y;
      bfm_cfg[i]        = noc_bfm_configuration::type_id::create($sformatf("bfm_cfg[%0d][%0d]", y, x));
      bfm_cfg[i].tx_vif = tx_vif[i];
      bfm_cfg[i].rx_vif = rx_vif[i];
    end
  endfunction

  `tue_object_default_constructor(noc_fabric_env_configuration)
  `uvm_object_utils(noc_fabric_env_configuration)
endclass
`endif
