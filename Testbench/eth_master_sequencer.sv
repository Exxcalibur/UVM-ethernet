class eth_samp_seq extends uvm_sequence #(eth_packet);
    eth_packet pkt;
	//`uvm_sequence_utils(eth_samp_seq, eth_master_sequencer)
    `uvm_object_utils(eth_samp_seq)    
    function new(string name="eth_samp_seq");
        super.new(name);
    endfunction : new
    
    virtual task body();
	    if(starting_phase!=null)
		    starting_phase.raise_objection(this);
	    repeat(10)
		begin
        `uvm_do_with(req, {req.mac_dest==48'hffff_ffff_ffff;
                           req.payload.size==46;
                           req.crc_ok==GOOD_CRC;})
		end
		if(starting_phase!=null)
		    starting_phase.drop_objection(this);
    endtask : body
endclass : eth_samp_seq

class eth_master_sequencer extends uvm_sequencer #(eth_packet);
    `uvm_sequencer_utils(eth_master_sequencer)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_update_sequence_lib_and_item(eth_packet)
    endfunction: new
	
	function void build_phase(uvm_phase phase);
	     super.build_phase(phase);
    endfunction : build_phase
    
	virtual task main_phase(uvm_phase phase);
	    eth_samp_seq my_seq;
		super.main_phase(phase);
		my_seq=new("my_seq");
		my_seq.starting_phase=phase;
		my_seq.start(this);
	endtask : main_phase
	
endclass : eth_master_sequencer
