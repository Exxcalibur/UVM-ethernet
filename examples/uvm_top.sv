/*
   UVM top level template
*/
`include "interface.sv"
module test_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "class.sv"


   
    reg clk_i;

    // Interfaces
    eth_if_in    eth_if_in_inst   [4](~clk_i,~clk_i);
    eth_if_sw    eth_if_sw_inst   [4](~clk_o);
    eth_if_cfig  eth_if_cfig_inst    (~clk_upi); 
    
	// clock gen
    initial begin
        clk_i=1'b0;
        forever #10 clk_i=~clk_i;
    end
 
 
    // DUT instance
 
     eth_swt         DUT( eth_if_in_inst[0]
                         );
 
     initial  begin
	 
	     // pass virtual interface
	     // uvm_config_db #( TYPE )::set( PREFIX, "PATH", "FIELD NAME", VALUE);
         uvm_config_db #(virtual eth_if_in.inp)::set(null,
                                                    "uvm_test_top",
                                                     "vif",
                                                     eth_if_in_inst[0]);
		uvm_top.finish_on_completion  = 1;
         // start test                                      
         run_test("testcase");  // Or use runtime opt: +UVM_TESTNAME=testcase
		                        // run_test();
     end
 
     initial begin
         $dumpfile("dump.vcd");
         $dumpvars();
     end
	 
 endmodule
 
/*
  dut_config, includeing virtual interfaces
*/
class dut_config extends uvm_object;
   `uvm_object_utils(dut_config)

   virtual dut_if dut_vi;
     // optionally add other config fields as needed
     
endclass // my_dut_config


/*
   UVM test template template
*/
class testcase extends uvm_test;
    `uvm_component_utils(testcase)
    
	dut_config dut_config_0;
    environment environment_inst;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		
		dut_config_0 = new();

	    if(!uvm_config_db #(virtual eth_if_in.inp)::get( this, 
		                                                  "", 
		                                                 "vif", 
		                                                 dut_config_0.dut_vi
														 )
		)
          `uvm_fatal("NOVIF", "No virtual interface set")
		  
	    // other DUT configuration settings
	    uvm_config_db #(dut_config)::set(this, 
		                                 "*", 
		                                 "dut_config", 
		                                 dut_config_0);
        //set_config_string("environment_inst.eth_master_sequencer_inst","default_sequence","eth_samp_seq");
        //set_config_object ("environment_inst.*","configuration",cfg);
		environment_inst=environment::type_id::create("environment_inst", this);

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
        

