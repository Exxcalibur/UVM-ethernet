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
    
    // uvm field might not provide the best perf
    // for better perf, users have to implement a few built-in functions 
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

    /* section for better perf begins*/
    //function void do_copy(uvm_object rhs);
    //    my_transaction rhs_;
    //    super.do_copy(rhs);
    //    $cast(rhs_, rhs);
    //    mac_dest  = rhs_.mac_dest;
    //endfunction: do_copy
    //
    //function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  my_transaction rhs_;
    //  bit status = 1;
    //
    //  status &= super.do_compare(rhs, comparer);
    //  $cast(rhs_, rhs);

    //  status &= comparer.compare_field("mac_dest",  mac_dest,  rhs_.mac_dest,  $bits(mac_dest));
  
    //  return(status);
    //endfunction: do_compare 
    /* section for better perf ends*/

endclass: my_transaction

//
/*****************************************
  sequence examples: sequence of transactions
*****************************************/

class my_basic_seq extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(my_basic_seq)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
        my_transaction tx;
        // first sample trans
        tx = my_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() );
        finish_item(tx);

        // or using macro: second sample trans
        tx = my_transaction::type_id::create("tx");
        `uvm_do_with(req, {req.mac_dest == 48'hffff_ffff_ffff;
                           req.payload.size == 46;
                           req.crc_ok == GOOD_CRC;})

        // don't add objections here. let highter level handle
    
    endtask: body
   
endclass: my_basic_seq

/*****************************************
  sequence examples: sequence of sequences
*****************************************/

class my_seq_of_basic_seqs extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(my_seq_of_basic_seqs)
    `uvm_declare_p_sequencer(uvm_sequencer#(my_transaction))
    
    rand int n;
    
    constraint how_many { n inside {[2:10]}; }
    
    function new (string name = "");
        super.new(name);
    endfunction: new

    task body;
        repeat(n) begin
          my_basic_seq seq;
          seq = my_basic_seq::type_id::create("seq");
          assert( seq.randomize() );
          seq.start(p_sequencer);
        end
    endtask: body
   
endclass: my_seq_of_basic_seqs
  

typedef uvm_sequencer #(my_transaction) my_sequencer;



class my_agent extends uvm_agent;
    my_sequencer my_sequencer_inst;
    my_driver my_driver_inst;
    my_monitor my_monitor_inst;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
    uvm_analysis_port#(eth_packet) uap;
    uvm_analysis_port#(eth_packet) uap_mon;
    
    `uvm_component_utils_begin(eth_agent)
        `uvm_field_object (my_sequencer_inst , UVM_ALL_ON)
    	`uvm_field_object (my_driver_inst    , UVM_ALL_ON)
    	`uvm_field_object (my_monitor_inst   , UVM_ALL_ON)
    `uvm_component_utils_end
endclass : my_agent

function void my_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE)
    begin
        my_sequencer_inst = my_sequencer::type_id::create("my_sequencer_inst",this);
    	my_driver_inst = my_driver::type_id::create("my_driver_inst",this);
    	my_monitor_inst = my_monitor::type_id::create("my_monitor_inst",this);
    end
    else
        my_monitor_inst = my_monitor::type_id::create("my_monitor_inst",this);
endfunction : build_phase

function void my_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE)
    begin
        my_driver_inst.seq_item_port.connect(my_sequencer_inst.seq_item_export);
    	this.uap = my_driver_inst.uap;
        this.uap_mon = my_monitor_inst.uap;
    end
    else
    begin
        this.uap_mon = my_monitor_inst.uap;
    end
endfunction : connect_phase



/*****************************************
  environment template
*****************************************/

class my_environment extends uvm_env;
    `uvm_component_utils(my_environment)
    
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
        //my_driver_inst.assign_vi(vif);
    endfunction : assign_vi
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : my_environment

function void my_environment::build_phase(uvm_phase phase);
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

function void my_environment::connect_phase(uvm_phase phase);
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

/*****************************************
   UVM test template 
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
        //set_config_string("environment_inst.my_sequencer_inst","default_sequence","eth_samp_seq");
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
        assert( my_seq.randomize() with {my_seq.n > 10;});
        phase.raise_objection(this);
        my_seq.start(my_environment_inst.my_agent_inst.my_sequencer_inst);
        phase.drop_objection(this);
    endtask // run_phase

endclass: my_testcase_basic
