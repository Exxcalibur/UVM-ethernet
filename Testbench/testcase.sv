class testcase extends uvm_test;
    `uvm_component_utils(testcase)
    
    environment environment_inst;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        environment_inst=new("environment_inst",this);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //set_config_string("environment_inst.eth_master_sequencer_inst","default_sequence","eth_samp_seq");
        //set_config_object ("environment_inst.*","configuration",cfg);
		uvm_config_db#(uvm_object_wrapper)::set(this,
		                                        "environment_inst.eth_agent_input_inst.eth_master_sequencer_inst.main_phase",
												"default_sequence",
												eth_samp_seq::type_id::get());
    endfunction : build_phase
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //environment_inst.assign_vi(test_top.eth_if_in_inst);
    endfunction : connect_phase
    
    virtual task main_phase(uvm_phase phase);
        environment_inst.eth_agent_input_inst.eth_master_sequencer_inst.print();
        
        #300;
        global_stop_request();
    endtask : main_phase
endclass : testcase
        