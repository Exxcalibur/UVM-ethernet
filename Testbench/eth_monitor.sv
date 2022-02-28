typedef enum {in_mon, sw_mon} mon_type;

class eth_monitor extends uvm_monitor;
    virtual eth_if_in.inp_rc vif_in;
	uvm_analysis_port #(eth_packet) uap;
    mon_type mon_type_inst;
    
	extern function new(string name, uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
    extern task get_one_cycle(ref logic valid, ref logic [127:0] data);
	extern task receive_pkt(ref eth_packet get_pkt);
    //extern task receive_pkt_sw(ref eth_packet get_pkt);
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
        `uvm_info("MONITOR::main_phase","write pkg",UVM_LOW)
        pkt.print();
		uap.write(pkt);
	end
endtask : main_phase

task eth_monitor::get_one_cycle(ref logic valid,
                                ref logic [127:0] data);
begin
    @(vif_in.cb_rc);
	data=vif_in.cb_rc.data;
	valid=vif_in.cb_rc.data_valid;
end
endtask : get_one_cycle

task eth_monitor::receive_pkt(ref eth_packet get_pkt);
    byte unsigned          data_q[$]          ;
	byte unsigned          data_array[]       ;
	logic         [127:0]  data               ;
	logic                  valid        =1'b0 ;
	int                    data_size          ;
    int                    pl_size            ;
	while(valid!=1'b1)
	begin
	    get_one_cycle(valid,data);
        //$display("%d",valid);
        if(valid===1'bx)
            valid=1'b0;
        //`uvm_info("MONITOR::receive_pkt","wait for data",UVM_LOW)
	end
    while(valid)
	begin
        for(int j=0;j<=15;j++)
	    data_q.push_back({data[127-j*8],data[126-j*8],data[125-j*8],data[124-j*8],
                          data[123-j*8],data[122-j*8],data[121-j*8],data[120-j*8]});
                          
		get_one_cycle(valid,data);
        //`uvm_info("MONITOR::receive_pkt","getting data",UVM_LOW)
	end
    data_size=data_q.size();    // in 16 bytes
	data_array=new[data_size];
	for(int i=0; i<data_size;i++)
	begin
	    data_array[i]=data_q[i];
	end
    pl_size=data_size;
    if(pl_size>0)
    pl_size=pl_size-18;
    
	get_pkt.payload=new[pl_size];
    //`uvm_info("MONITOR::receive_pkt","unpack data",UVM_LOW)
	get_pkt.unpack_bytes(data_array);
endtask : receive_pkt