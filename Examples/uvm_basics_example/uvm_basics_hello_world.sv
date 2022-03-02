
// Filename: uvm_basics_hello_world.sv

//----------------------------------------------------------------------
//  Copyright (c) 2013 by Mentor Graphics Corp.
//  Copyright (c) 2011 by Doulos Ltd.
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
// Session 2: UVM "Hello World"

// Original Author: John Aynsley, Doulos
// Updated: Tom Fitzpatrick, Mentor Graphics
// Date:   10-Mar-2011
// Date:   31-Jul-2013


`include "uvm_macros.svh"

interface dut_if();

endinterface: dut_if


module dut(dut_if _if);

endmodule: dut


package my_pkg;

  import uvm_pkg::*;

  class my_env extends uvm_env;

    `uvm_component_utils(my_env)
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
       // instantiate components (if any)
    endfunction: build_phase
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
    endtask: run_phase
     
  endclass: my_env
  
  
  class my_test extends uvm_test;
  
    `uvm_component_utils(my_test)
    
    my_env my_env_h;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      my_env_h = my_env::type_id::create("my_env_h", this);
    endfunction: build_phase
    
  endclass: my_test
  
  
endpackage: my_pkg


module top;

  import uvm_pkg::*;
  import my_pkg::*;
  
  dut_if dut_if1 ();
  
  dut    dut1 ( ._if(dut_if1) );

  initial
  begin
    run_test("my_test");
  end

endmodule: top
