class environment extends uvm_env;
    `uvm_component_utils(environment)
    
    eth_agent eth_agent_input_inst;
    eth_model eth_model_inst;
    eth_scoreboard eth_scoreboard_inst;
    
    uvm_tlm_analysis_fifo #(eth_packet) agt_scb_fifo;
    uvm_tlm_analysis_fifo #(eth_packet) agt_mdl_fifo;
    uvm_tlm_analysis_fifo #(eth_packet) mdl_scb_fifo;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void assign_vi(virtual eth_if_in vif);
        //eth_master_driver_inst.assign_vi(vif);
    endfunction : assign_vi
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : environment

function void environment::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "start building", UVM_LOW)
    eth_agent_input_inst=new("eth_agent_input_inst",this);
    eth_agent_input_inst.is_active=UVM_ACTIVE;
    eth_model_inst=new("eth_model_inst",this);
    eth_scoreboard_inst=new("eth_scoreboard_inst",this);
    agt_mdl_fifo=new("agt_mdl_fifo",this);
    agt_scb_fifo=new("agt_scb_fifo",this);
    mdl_scb_fifo=new("mdl_scb_fifo",this);
    `uvm_info(get_full_name(),"building end",UVM_LOW)
endfunction : build_phase

function void environment::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_full_name(),"start connecting",UVM_LOW)
    eth_agent_input_inst.uap.connect(agt_mdl_fifo.analysis_export);
    eth_model_inst.port.connect(agt_mdl_fifo.blocking_get_export);
    eth_model_inst.uap.connect(mdl_scb_fifo.analysis_export);
    eth_scoreboard_inst.exp_port.connect(mdl_scb_fifo.blocking_get_export);
    eth_scoreboard_inst.act_port.connect(agt_scb_fifo.blocking_get_export);
    eth_agent_input_inst.uap_mon.connect(agt_scb_fifo.analysis_export);
    `uvm_info(get_full_name(),"connecting end", UVM_LOW)
endfunction : connect_phase


