class eth_master_driver extends uvm_driver #(eth_packet);
    virtual eth_if_in.inp        vif       [4];
    virtual eth_if_cfig.cfig_tb  vif_cfig     ;  
    configuration cfg;
    eth_packet pkt_get;
	uvm_analysis_port #(eth_packet) uap;
    //uvm_blocking_get_port #(eth_packet) get_port;
	`uvm_component_utils(eth_master_driver)
    
	function new(string name, uvm_component parent);
	    super.new(name, parent);
        //get_port=new("get_port",this);
        pkt_get=new("pkt_get");
	endfunction : new
    
	function void assign_vi(virtual eth_if_in vif);
        //this.vif=vif;
    endfunction : assign_vi
    
    virtual function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       uap=new("uap",this);
	   if(!uvm_config_db#(virtual eth_if_in.inp)::get(this,"","vif[0]",vif[0]))
	       `uvm_fatal("driver","error getting interface 0")
           
       if(!uvm_config_db#(virtual eth_if_in.inp)::get(this,"","vif[1]",vif[1]))
	       `uvm_fatal("driver","error getting interface 1")
           
       if(!uvm_config_db#(virtual eth_if_in.inp)::get(this,"","vif[2]",vif[2]))
	       `uvm_fatal("driver","error getting interface 2")
           
       if(!uvm_config_db#(virtual eth_if_in.inp)::get(this,"","vif[3]",vif[3]))
	       `uvm_fatal("driver","error getting interface 3")
           
       if(!uvm_config_db#(virtual eth_if_cfig.cfig_tb)::get(this,"","vif_cfig",vif_cfig))
           `uvm_fatal("driver","error getting config interface")
	   /*
		uvm_object tmp;
        super.build_phase(phase);
        assert(get_config_object("configuration",tmp));
        $cast(cfg,tmp);
        if(cfg==null)
            `uvm_info("cfg initialization","cfg initialization failure",UVM_LOW)
        if(cfg.vif_in==null)
            `uvm_info("cfg vif initialization","cfg vif initialization failure",UVM_LOW)
        //vif=cfg.vif_in;
        if(vif==null)
            `uvm_info("vif initialization","vif initialization failure",UVM_LOW)
    */
	endfunction : build_phase   
    
	extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task get_and_drive_seq();
	extern virtual protected task reset_signals();
	extern virtual protected task drive_transfer(eth_packet req);
endclass : eth_master_driver

task eth_master_driver::main_phase(uvm_phase phase);
begin
    super.main_phase(phase);
    reset_signals();
    //get_and_drive();
    get_and_drive_seq();
end
endtask: main_phase

task eth_master_driver::reset_signals();
fork
    begin
        `uvm_info(get_full_name(),"reset running", UVM_LOW)
        vif[0].rst_n<=1'b0;
        vif[0].cb.data_valid<=1'b0;
        vif[1].cb.data_valid<=1'b0;
        vif[2].cb.data_valid<=1'b0;
        vif[3].cb.data_valid<=1'b0;
        repeat(4)@(negedge vif[0].clock_tb);
        vif[0].rst_n<=1'b1;
    end
    begin
        vif_cfig.rst_n<=1'b0;
        repeat(2)@(vif_cfig.cb);
        vif_cfig.rst_n<=1'b1;
    end
join
endtask : reset_signals


task eth_master_driver::get_and_drive_seq();
    int cnt=0;
    forever 
	begin 
        eth_packet req;	
	    `uvm_info(get_full_name(),"seq driver running", UVM_LOW)
        seq_item_port.get_next_item(req);
        cnt=cnt+1;
        $display("driver get pkg number %d", cnt);
        //req.print();
	    drive_transfer(req);
        uap.write(req);
        seq_item_port.item_done();
		`uvm_info(get_full_name(),"seq end driver run", UVM_LOW)
	end
endtask : get_and_drive_seq

task eth_master_driver::drive_transfer(eth_packet req);
begin 
    byte unsigned data_q[];
    int data_size; 
    int j;
    `uvm_info(get_full_name(),"drive transfer", UVM_LOW)
    //#30 trans.print();
    data_size=req.pack_bytes(data_q)/(8*16);
    @vif[0].cb;
    for(int i=0;i<data_size;i=i+1)
    begin
        j=16*i;
        @(vif[0].cb);
        vif[0].cb.data<={data_q[j],data_q[j+1],
                   data_q[j+2],data_q[j+3],
                   data_q[j+4],data_q[j+5],
                   data_q[j+6],data_q[j+7],
                   data_q[j+8],data_q[j+9],
                   data_q[j+10],data_q[j+11],
                   data_q[j+12],data_q[j+13],
                   data_q[j+14],data_q[j+15]};
				   
        vif[0].cb.data_valid<=1'b1;
		vif[0].cb.data_bytes<=4'hf;
        
        if(i<1)
            vif[0].cb.block_tag<=10'h100;
        else if(i<data_size-1)
            vif[0].cb.block_tag<=10'h102;
        else
            vif[0].cb.block_tag<=10'h101;
        
        if(i!=0)
            vif[0].cb.sof<=1'b0;
        else
            vif[0].cb.sof<=1'b1;
            
        if(i==data_size-1)
            vif[0].cb.eof<=1'b1;
        else
            vif[0].cb.eof<=1'b0;          
    end
    @(vif[0].cb);
    vif[0].cb.data_valid<=1'b0;
end  
endtask : drive_transfer
