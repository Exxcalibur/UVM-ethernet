
// Filename: uvm_basics_complete.sv

//----------------------------------------------------------------------
//  Copyright (c) 2013 by Mentor Graphics Corp.
//  Copyright (c) 2011-2012 by Doulos Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//----------------------------------------------------------------------

// Source code example for Mentor Graphics Verification Academy UVM Basics Module
// Sessions 3-8

// Original Author: John Aynsley, Doulos
// Updated: Tom Fitzpatrick, Mentor Graphics
// Date:   10-Mar-2011
// Date:   19-Oct-2012  Updated for UVM 1.1 by replacing start_item(seq) with seq.start() 
// Date:   31-Jul-2013  Modified code to be consistent with UVM Cookbook

`include "uvm_macros.svh"

interface dut_if();

  logic clock, reset;
  logic cmd;
  logic [7:0] addr;
  logic [7:0] data;

endinterface: dut_if


module dut(dut_if _if);

  import uvm_pkg::*;

  always @(posedge _if.clock)
  begin
    `uvm_info("mg", $psprintf("DUT received cmd=%b, addr=%d, data=%d",
                               _if.cmd, _if.addr, _if.data), UVM_NONE);
  end
  
endmodule: dut


package my_sequences;

  import uvm_pkg::*;

  class my_transaction extends uvm_sequence_item;
  
    `uvm_object_utils(my_transaction)
  
    rand bit cmd;
    rand int addr;
    rand int data;
  
    constraint c_addr { addr >= 0; addr < 256; }
    constraint c_data { data >= 0; data < 256; }
    
    function new (string name = "");
      super.new(name);
    endfunction: new
    
    function string convert2string;
      return $psprintf("cmd=%b, addr=%0d, data=%0d", cmd, addr, data);
    endfunction: convert2string
    /*
    function void do_copy(uvm_object rhs);
      my_transaction rhs_;
      super.do_copy(rhs);
      $cast(rhs_, rhs);
      cmd  = rhs_.cmd;
      addr = rhs_.addr;
      data = rhs_.data;
    endfunction: do_copy
    
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      my_transaction rhs_;
      bit status = 1;
    
      status &= super.do_compare(rhs, comparer);
      $cast(rhs_, rhs);

      status &= comparer.compare_field("cmd",  cmd,  rhs_.cmd,  $bits(cmd));
      status &= comparer.compare_field("addr", addr, rhs_.addr, $bits(addr));
      status &= comparer.compare_field("data", data, rhs_.data, $bits(data));
  
      return(status);
    endfunction: do_compare
    */
  endclass: my_transaction


  class read_modify_write extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(read_modify_write)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      my_transaction tx;
      int a;
      int d;

      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      assert( tx.randomize() );
      tx.cmd = 1;
      finish_item(tx);

      a = tx.addr;      
      d = tx.data;
      ++d;

      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      tx.cmd = 1;
      tx.addr = a;
      tx.data = d;
      finish_item(tx);
    endtask: body
   
  endclass: read_modify_write
  

  class seq_of_commands extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(seq_of_commands)
    `uvm_declare_p_sequencer(uvm_sequencer#(my_transaction))
    
    rand int n;
    
    constraint how_many { n inside {[2:4]}; }
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      repeat(n)
      begin
        read_modify_write seq;
        seq = read_modify_write::type_id::create("seq");
        assert( seq.randomize() );
        seq.start(p_sequencer);
      end
    endtask: body
   
  endclass: seq_of_commands
  
endpackage: my_sequences


package my_pkg;

  import uvm_pkg::*;
  import my_sequences::*;


  typedef uvm_sequencer #(my_transaction) my_sequencer;

  class my_dut_config extends uvm_object;
     `uvm_object_utils(my_dut_config)

     virtual dut_if dut_vi;
     // optionally add other config fields as needed
     
  endclass // my_dut_config
   
   
  class my_driver extends uvm_driver #(my_transaction);
  
    `uvm_component_utils(my_driver)

     my_dut_config dut_config_0;
     virtual dut_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
       assert( uvm_config_db #(my_dut_config)::get(this, "", "dut_config", 
						   dut_config_0) );
       dut_vi = dut_config_0.dut_vi;
       // other config settings from dut_config_0 object as needed
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        my_transaction tx;
        
        @(posedge dut_vi.clock);
        seq_item_port.get(tx);
        
        // Wiggle pins of DUT
        dut_vi.cmd  = tx.cmd;
        dut_vi.addr = tx.addr;
        dut_vi.data = tx.data;
      end
    endtask: run_phase

  endclass: my_driver


  class my_monitor extends uvm_monitor;
  
    `uvm_component_utils(my_monitor)

     uvm_analysis_port #(my_transaction) aport;
    
     my_dut_config dut_config_0;
     virtual dut_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
       dut_config_0 = my_dut_config::type_id::create("config");
       aport = new("aport", this);
       assert( uvm_config_db #(my_dut_config)::get(this, "", "dut_config",
						   dut_config_0) );
       dut_vi = dut_config_0.dut_vi;
       // other config settings as needed
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        my_transaction tx;
        
        @(posedge dut_vi.clock);
        tx = my_transaction::type_id::create("tx");
        tx.cmd  = dut_vi.cmd;
        tx.addr = dut_vi.addr;
        tx.data = dut_vi.data;
        
        aport.write(tx);
      end
    endtask: run_phase

  endclass: my_monitor


  class my_agent extends uvm_agent;

    `uvm_component_utils(my_agent)
    
    uvm_analysis_port #(my_transaction) aport;
    
    my_sequencer my_sequencer_h;
    my_driver    my_driver_h;
    my_monitor   my_monitor_h;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
       aport = new("aport", this);
       my_sequencer_h = my_sequencer::type_id::create("my_sequencer_h", this);
       my_driver_h    = my_driver   ::type_id::create("my_driver_h"   , this);
       my_monitor_h   = my_monitor  ::type_id::create("my_monitor_h"  , this);
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
      my_driver_h.seq_item_port.connect( my_sequencer_h.seq_item_export );
      my_monitor_h.       aport.connect( aport );
    endfunction: connect_phase
    
  endclass: my_agent
  
  
  class my_subscriber extends uvm_subscriber #(my_transaction);
  
    `uvm_component_utils(my_subscriber)
    
    bit cmd;
    int addr;
    int data;
        
    covergroup cover_bus;
      coverpoint cmd;
      coverpoint addr { 
        bins a[16] = {[0:255]};
      }
      coverpoint data {
        bins d[16] = {[0:255]};
      }
    endgroup: cover_bus
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
      cover_bus = new;  
    endfunction: new

    function void write(my_transaction t);
      `uvm_info("mg", $psprintf("Subscriber received tx %s", t.convert2string()), UVM_NONE);
      
      cmd  = t.cmd;
      addr = t.addr;
      data = t.data;
      cover_bus.sample();
      /*
      begin
        my_transaction expected;
        expected = new;
        expected.copy(t);
        if ( !t.compare(expected))
          `uvm_error("mg", "Transaction differs from expected");
      end
      */
    endfunction: write

  endclass: my_subscriber
  
  
  class my_env extends uvm_env;

    `uvm_component_utils(my_env)
    
    UVM_FILE file_h;
    my_agent      my_agent_h;
    my_subscriber my_subscriber_h;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      my_agent_h      = my_agent     ::type_id::create("my_agent_h", this);
      my_subscriber_h = my_subscriber::type_id::create("my_subscriber_h", this);
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
      my_agent_h.aport.connect( my_subscriber_h.analysis_export );
    endfunction: connect_phase
    
    function void start_of_simulation_phase(uvm_phase phase);
    
      //uvm_top.set_report_verbosity_level_hier(UVM_NONE);
      uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
      //uvm_top.set_report_severity_action_hier(UVM_INFO, UVM_NO_ACTION);
      //uvm_top.set_report_id_action_hier("ja", UVM_NO_ACTION);
      
      file_h = $fopen("uvm_basics_complete.log", "w");
      uvm_top.set_report_default_file_hier(file_h);
      uvm_top.set_report_severity_action_hier(UVM_INFO, UVM_DISPLAY + UVM_LOG);

    endfunction: start_of_simulation_phase

  endclass: my_env
  
  
  class my_test extends uvm_test;
  
    `uvm_component_utils(my_test)
    
     my_dut_config dut_config_0;
    
     my_env my_env_h;   
   
     function new(string name, uvm_component parent);
	super.new(name, parent);
     endfunction: new
    
     function void build_phase(uvm_phase phase);
	dut_config_0 = new();

	if(!uvm_config_db #(virtual dut_if)::get( this, "", "dut_vi", 
						  dut_config_0.dut_vi))
          `uvm_fatal("NOVIF", "No virtual interface set")
	// other DUT configuration settings
	uvm_config_db #(my_dut_config)::set(this, "*", "dut_config", 
					    dut_config_0);
	my_env_h = my_env::type_id::create("my_env_h", this);
     endfunction: build_phase
     
  endclass // my_test

  class test1 extends my_test;
   `uvm_component_utils(test1)

     function new(string name, uvm_component parent);
	super.new(name, parent);
     endfunction: new
    
     task run_phase(uvm_phase phase);
	read_modify_write seq;
	seq = read_modify_write::type_id::create("seq");
	phase.raise_objection(this);
	seq.start(my_env_h.my_agent_h.my_sequencer_h);
	phase.drop_objection(this);
     endtask // run_phase
  endclass: test1
   
  class test2 extends my_test;
     `uvm_component_utils(test2)
	
     function new(string name, uvm_component parent);
	super.new(name, parent);
     endfunction: new
    
     task run_phase(uvm_phase phase);
	seq_of_commands seq;
	seq = seq_of_commands::type_id::create("seq");
	assert( seq.randomize() );
	phase.raise_objection(this);
	seq.start( my_env_h.my_agent_h.my_sequencer_h );
	phase.drop_objection(this);
     endtask: run_phase
     
  endclass: test2
   
  class test3 extends my_test;
     `uvm_component_utils(test3)
	
     function new(string name, uvm_component parent);
	super.new(name, parent);
     endfunction: new
    
     task run_phase(uvm_phase phase);
	seq_of_commands seq;
	seq = seq_of_commands::type_id::create("seq");
	seq.how_many.constraint_mode(0);
	assert( seq.randomize() with {seq.n > 10 && seq.n < 20;});
	phase.raise_objection(this);
	seq.start( my_env_h.my_agent_h.my_sequencer_h );
	phase.drop_objection(this);
     endtask: run_phase
     
  endclass: test3
  
endpackage: my_pkg


module top;

  import uvm_pkg::*;
  import my_pkg::*;
  
  dut_if dut_if1 ();
  
  dut    dut1 ( ._if(dut_if1) );

  // Clock and reset generator
  initial
  begin
    dut_if1.clock = 0;
    forever #5 dut_if1.clock = ~dut_if1.clock;
  end

  initial
  begin
    dut_if1.reset = 1;
    repeat(3) @(negedge dut_if1.clock);
    dut_if1.reset = 0;
  end

  initial
  begin: blk
     uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top",
	                                  "dut_vi", dut_if1);

     uvm_top.finish_on_completion  = 1;
    
     run_test();
  end

endmodule: top
