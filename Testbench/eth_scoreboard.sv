class eth_scoreboard extends uvm_scoreboard;
    eth_packet exp_que[$];
    uvm_blocking_get_port #(eth_packet) exp_port;
    uvm_blocking_get_port #(eth_packet) act_port;
    `uvm_component_utils(eth_scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass : eth_scoreboard

function void eth_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port=new("exp_port",this);
    act_port=new("act_port",this);
endfunction

task eth_scoreboard::main_phase(uvm_phase phase);
    eth_packet get_exp, get_act, tmp;
    int cnt_good=0;
    int cnt_bad=0;
    bit result;
    
    super.main_phase(phase);
    fork
       forever
       begin
           exp_port.get(get_exp);
           exp_que.push_back(get_exp);
       end
       forever
       begin
           act_port.get(get_act);
           if(exp_que.size()>0)
           begin
               tmp=exp_que.pop_front();
               result=get_act.compare(tmp);
               if(result)
               begin
                   cnt_good=cnt_good+1;
                   `uvm_info("SCOREBOARD","compare successfully",UVM_LOW);
                   $display("correct packet NO %d",cnt_good);
                   $display("error packet NO %d",cnt_bad);
                   
               end
               else
               begin
                   cnt_bad=cnt_bad+1;
                   `uvm_error("SCOREBOARD","compare FAILED!!");
                   $display("the expected pkt is");
                   tmp.print();
                   $display("the actual pkt is");
                   get_act.print();
                   $display("correct packet NO %d",cnt_good);
                   $display("error packet NO %d",cnt_bad);
               end
           end
           else
           begin
               `uvm_error("SCOREBOARD", "ERROR received from DUT, exp_que is empty");
               get_act.print();
           end
       end
    join
endtask
    