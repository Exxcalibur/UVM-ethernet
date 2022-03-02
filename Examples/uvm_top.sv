/*****************************************
   UVM top level template
*****************************************/
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
        forever #10 clk_i = ~clk_i;
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
 
/*****************************************
  dut_config, includeing virtual interfaces
*****************************************/
class my_dut_config extends uvm_object;
   `uvm_object_utils(my_dut_config)

    virtual my_dut_if my_dut_vi;
     // optionally add other config fields as needed
     
endclass // my_dut_config


/*****************************************
  sequence item examples
*****************************************/

typedef enum{GOOD_CRC, BAD_CRC} crc_kind;

class my_transaction extends uvm_sequence_item;
    rand bit   [47:0]           mac_dest        ;
    rand bit   [47:0]           mac_sour        ;
    rand bit   [15:0]           length          ;
    rand byte                   payload    []   ;
    rand bit   [31:0]           crc             ;
    rand crc_kind               crc_ok          ;

    constraint c_my_payload_size {payload.size inside {[46:1500]};}
    constraint c_my_length {length==payload.size;}
    
    `uvm_object_utils_begin(my_transaction)
        `uvm_field_int           (mac_dest, UVM_DEFAULT)
    	`uvm_field_int           (mac_sour,UVM_DEFAULT)
    	`uvm_field_int           (length, UVM_DEFAULT)
    	`uvm_field_array_int     (payload, UVM_DEFAULT)
    	`uvm_field_int           (crc, UVM_DEFAULT)
        `uvm_field_enum          (crc_kind, crc_ok, UVM_ALL_ON|UVM_NOPACK)
    `uvm_object_utils_end
    
    extern function void post_randomize();
    
    function new(string name="my_transaction");
        super.new(name);
    endfunction: new

endclass: my_transaction

/*****************************************
   UVM test template template
*****************************************/
class my_testcase extends uvm_test;
    `uvm_component_utils(my_testcase)
    
    my_dut_config dut_config_0;
    my_environment my_environment_inst;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        dut_config_0 = new();

        if(!uvm_config_db #(virtual my_eth_if_in.inp)::get( this, 
    	                                         "", 
    	                                         "vif", 
    	                                         my_dut_config_0.dut_vi
    						)
          ) begin
            `uvm_fatal("NOVIF", "No virtual interface set")
        end
    	  
         // other DUT configuration settings
         uvm_config_db #(my_dut_config)::set(this, 
                                              "*", 
                                      "dut_config", 
                                     my_dut_config_0);
        //set_config_string("environment_inst.eth_master_sequencer_inst","default_sequence","eth_samp_seq");
        //set_config_object ("environment_inst.*","configuration",cfg);
        my_environment_inst=environment::type_id::create("my_environment_inst", this);

    endfunction : build_phase
    
endclass : my_testcase
        
class my_testcase_basic extends my_testcase;
    `uvm_component_utils(my_testcase_basic)
    
   
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        my_basic_seq my_seq;    // user sequence
        my_seq = my_basic_seq::type_id::create("my_seq");
        assert( my_seq.randomize() with {my_seq.n > 10 && my_seq.n < 20;});
        phase.raise_objection(this);
        my_seq.start(my_environment_inst.my_agent_inst.my_sequencer_inst);
        phase.drop_objection(this);
    endtask // run_phase

endclass: my_testcase_basic
