class generator extends uvm_component;
    `uvm_component_utils(generator)
    uvm_blocking_put_port #(eth_packet) put_port;
    eth_packet pkt;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        put_port=new("put_port",this);
        pkt=new("pkt");
    endfunction
    
    virtual task run();
    forever
    begin
    
    #30
        pkt.randomize();
        put_port.put(pkt);
    end
    endtask: run
endclass : generator