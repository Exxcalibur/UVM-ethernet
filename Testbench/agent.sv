class eth_agent extends uvm_agent;
    eth_master_sequencer eth_master_sequencer_inst;
	eth_master_driver eth_master_driver_inst;
	eth_monitor eth_monitor_inst;
	
	function new(string name, uvm_component parent);
	    super.new(name, parent);
	endfunction : new
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
	uvm_analysis_port#(eth_packet) uap;
    uvm_analysis_port#(eth_packet) uap_mon;
	
	`uvm_component_utils_begin(eth_agent)
	    `uvm_field_object (eth_master_sequencer_inst , UVM_ALL_ON)
		`uvm_field_object (eth_master_driver_inst    , UVM_ALL_ON)
		`uvm_field_object (eth_monitor_inst          , UVM_ALL_ON)
	`uvm_component_utils_end
endclass : eth_agent

function void eth_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(is_active==UVM_ACTIVE)
	begin
	    eth_master_sequencer_inst=eth_master_sequencer::type_id::create("eth_master_sequencer_inst",this);
		eth_master_driver_inst=eth_master_driver::type_id::create("eth_master_driver_inst",this);
		eth_monitor_inst=eth_monitor::type_id::create("eth_monitor_inst",this);
	end
    else
	    eth_monitor_inst=eth_monitor::type_id::create("eth_monitor_inst",this);
endfunction : build_phase

function void eth_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	if(is_active==UVM_ACTIVE)
	begin
	    eth_master_driver_inst.seq_item_port.connect
		(eth_master_sequencer_inst.seq_item_export);
		this.uap=eth_master_driver_inst.uap;
        this.uap_mon=eth_monitor_inst.uap;
	end
	else
	begin
	    this.uap_mon=eth_monitor_inst.uap;
	end
endfunction : connect_phase
