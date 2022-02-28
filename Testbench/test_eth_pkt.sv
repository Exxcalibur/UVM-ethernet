module test_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "class.sv"
    //`include "eth_packet.sv"
    //`include "configuration.sv"
    //`include "generator.sv"
    //`include "eth_master_sequencer.sv"
    //`include "eth_master_driver.sv"
    //`include "eth_monitor.sv"
    //`include "agent.sv"
    //`include "environment.sv"
    //`include "testcase.sv"  
   
    reg clk_i;
    reg clk_o;
    reg clk_upi;
   /* logic            data_valid;
    logic [127:0]    data;
    logic [3:0]      data_bytes;
    logic            sof;
    logic            eof;
    logic [9:0]      block_tag;
    logic            rst_n; */
    
    eth_if_in    eth_if_in_inst   [4](~clk_i,~clk_i);
    eth_if_sw    eth_if_sw_inst   [4](~clk_o);
    eth_if_cfig  eth_if_cfig_inst    (~clk_upi); 
 
 initial
 begin
 clk_i=1'b0;
 forever #10 clk_i=~clk_i;
 end
 
 initial
 begin
 clk_upi=1'b0;
 forever #15 clk_upi=~clk_upi;
 end
 
 initial
 begin
 clk_o=1'b1;
 forever #5 clk_o=~clk_o;
 end
 
 /*assign data_valid   =   eth_if_in_inst.data_valid;
 assign data         =   eth_if_in_inst.data;
 assign data_bytes   =   eth_if_in_inst.data_bytes;
 assign sof          =   eth_if_in_inst.sof;
 assign eof          =   eth_if_in_inst.eof;
 assign block_tag    =   eth_if_in_inst.block_tag;
 assign rst_n        =   eth_if_in_inst.rst_n; */
 
 
 eth_swt         DUT(.clk_ge                              (clk_o),
                     .clk_fe                              (clk_o),
                     .clk_upi                             (clk_upi),
                     .rst_n                               (eth_if_in_inst[0].rst_n),
                     .rst_upi_n                           (eth_if_cfig_inst.rst_n),
                     .upi_d                               (eth_if_cfig_inst.upi_d),
                     .upi_a                               (eth_if_cfig_inst.upi_a),
                     .upi_we                              (eth_if_cfig_inst.upi_we),
                     .upi_rd                              (eth_if_cfig_inst.upi_rd),
                     .upi_q                               (eth_if_cfig_inst.upi_q),
                     .data_valid_0                        (eth_if_in_inst[0].data_valid),
                     .data_0                              (eth_if_in_inst[0].data),
                     .data_bytes_0                        (eth_if_in_inst[0].data_bytes),
                     .sof_0                               (eth_if_in_inst[0].sof),
                     .eof_0                               (eth_if_in_inst[0].eof),
                     .block_tag_0                         (eth_if_in_inst[0].block_tag),
                     .data_valid_1                        (eth_if_in_inst[0].data_valid),
                     .data_1                              (eth_if_in_inst[0].data),
                     .data_bytes_1                        (eth_if_in_inst[0].data_bytes),
                     .sof_1                               (eth_if_in_inst[0].sof),
                     .eof_1                               (eth_if_in_inst[0].eof),
                     .block_tag_1                         (eth_if_in_inst[0].block_tag),
                     .data_valid_2                        (eth_if_in_inst[0].data_valid),
                     .data_2                              (eth_if_in_inst[0].data),
                     .data_bytes_2                        (eth_if_in_inst[0].data_bytes),
                     .sof_2                               (eth_if_in_inst[0].sof),
                     .eof_2                               (eth_if_in_inst[0].eof),
                     .block_tag_2                         (eth_if_in_inst[0].block_tag),
                     .data_valid_3                        (eth_if_in_inst[0].data_valid),
                     .data_3                              (eth_if_in_inst[0].data),
                     .data_bytes_3                        (eth_if_in_inst[0].data_bytes),
                     .sof_3                               (eth_if_in_inst[0].sof),
                     .eof_3                               (eth_if_in_inst[0].eof),
                     .block_tag_3                         (eth_if_in_inst[0].block_tag),
                     .switched_data_valid_0               (eth_if_sw_inst[0].sw_data_valid),
                     .switched_data_0                     (eth_if_sw_inst[0].sw_data),
                     .switched_data_bytes_0               (eth_if_sw_inst[0].sw_data_bytes),
                     .switched_sof_0                      (eth_if_sw_inst[0].sw_sof),
                     .switched_eof_0                      (eth_if_sw_inst[0].sw_eof),
                     .switched_block_tag_0                (eth_if_sw_inst[0].sw_block_tag),
                     .switched_data_valid_1               (eth_if_sw_inst[1].sw_data_valid),
                     .switched_data_1                     (eth_if_sw_inst[1].sw_data),
                     .switched_data_bytes_1               (eth_if_sw_inst[1].sw_data_bytes),
                     .switched_sof_1                      (eth_if_sw_inst[1].sw_sof),
                     .switched_eof_1                      (eth_if_sw_inst[1].sw_eof),
                     .switched_block_tag_1                (eth_if_sw_inst[1].sw_block_tag),
                     .switched_data_valid_2               (eth_if_sw_inst[2].sw_data_valid),
                     .switched_data_2                     (eth_if_sw_inst[2].sw_data),
                     .switched_data_bytes_2               (eth_if_sw_inst[2].sw_data_bytes),
                     .switched_sof_2                      (eth_if_sw_inst[2].sw_sof),
                     .switched_eof_2                      (eth_if_sw_inst[2].sw_eof),
                     .switched_block_tag_2                (eth_if_sw_inst[2].sw_block_tag),
                     .switched_data_valid_3               (eth_if_sw_inst[3].sw_data_valid),
                     .switched_data_3                     (eth_if_sw_inst[3].sw_data),
                     .switched_data_bytes_3               (eth_if_sw_inst[3].sw_data_bytes),
                     .switched_sof_3                      (eth_if_sw_inst[3].sw_sof),
                     .switched_eof_3                      (eth_if_sw_inst[3].sw_eof),
                     .switched_block_tag_3                (eth_if_sw_inst[3].sw_block_tag)
                     );
 
 initial
 begin
     uvm_config_db #(virtual eth_if_in.inp)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_master_driver_inst",
                                             "vif[0]",
                                             eth_if_in_inst[0]);
     uvm_config_db #(virtual eth_if_in.inp)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_master_driver_inst",
                                             "vif[1]",
                                             eth_if_in_inst[1]);
     uvm_config_db #(virtual eth_if_in.inp)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_master_driver_inst",
                                             "vif[2]",
                                             eth_if_in_inst[2]);
     uvm_config_db #(virtual eth_if_in.inp)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_master_driver_inst",
                                             "vif[3]",
                                             eth_if_in_inst[3]);   
     
     uvm_config_db #(virtual eth_if_in.inp_rc)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_monitor_inst",
                                             "eth_if_in.inp_rc",
                                             eth_if_in_inst[0]);                                        

     uvm_config_db #(virtual eth_if_cfig.cfig_tb)::set(null,
                                             "uvm_test_top.environment_inst.eth_agent_input_inst.eth_master_driver_inst",
                                             "vif_cfig",
                                             eth_if_cfig_inst);                                        
     run_test("testcase");
 end
 
 initial
 begin
     $dumpfile("test.dump");
     $dumpvars();
 end
 endmodule
