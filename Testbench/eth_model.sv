class eth_model extends uvm_component;
    uvm_blocking_get_port #(eth_packet) port;
    uvm_analysis_port #(eth_packet) uap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase( uvm_phase phase);
        super.build_phase(phase);
        port=new("port",this);
        uap=new("uap",this);
    endfunction
    
    extern task main_phase( uvm_phase phase);
endclass : eth_model

task eth_model::main_phase(uvm_phase phase);
    eth_packet pkt;
    super.main_phase(phase);
    forever
    begin
        port.get(pkt);
        uap.write(pkt);
    end
endtask
