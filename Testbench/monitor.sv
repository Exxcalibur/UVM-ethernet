class eth_monitor extends uvm_monitor;
    virtual eth_if_in.inp_rc vif_in;
	uvm_analysis_port #(eth_packet) uap;
	extern function new(string name, uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern task receive_pkt(ref eth_packet get_pkt);
	`uvm_component_utils(eth_monitor)
endclass : eth_monitor

function eth_monitor::new(string name, uvm_component parent);
    super.new(name,parent);
endfunction : new

function void eth_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(virtual eth_if_in.inp_rc)::get(this,"","eth_if_in.inp_rc",vif_in))
	    `uvm_fatal("eth_monitor","error in getting interface")
		uap=new("uap",this);
endfunction : build_phase

task eth_monitor::main_phase(uvm_phase phase);
    eth_packet pkt;
	super.main_phase(phase);
	forever
	begin
	    pkt=new();
		receive_pkt(pkt);
		uap.write(pkt);
	end
endtask : main_phase

task eth_monitor::get_one_cycle(ref logic valid,
                                ref logic [127:0] data);
    @vif.cb_rc;
	data<=vif.cb_rc.data;
	valid<=vif.cb_rc.data_valid;
endtask : get_one_cycle

task eth_monitor::receive_pkt(ref eth_packet get_pkt);
    bit [127:0] data_q[$];
	bit [127:0] data_array[];
	logic [127:0] data;
	logic valid=1'b0;
	int data_size;
	while(valid!=1'b1)
	begin
	    get_one_cycle(valid,data);
	end
    while(valid)
	begin
	    data_q.push_back(data);
		get_one_cycle(valid,data);
	end
    data_size=data_q.size();    // in 16 bytes
	data_array=new[data_size];
	for(int i=0; i<data_size;i++)
	begin
	    data_array[i]=data_q[i];
	end
	get_pkt.payload=new[data_size*16];
	data_size=get_pkt.unpack_bytes(data_array)/8;
endtask : receive_pkt