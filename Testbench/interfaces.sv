interface eth_if_in (input bit clock_tb, input bit clock_rc);
    logic            data_valid;
    logic [127:0]    data;
    logic [3:0]      data_bytes;
    logic            sof;
    logic            eof;
    logic [9:0]      block_tag;
    logic            rst_n;
    
    clocking cb@(posedge clock_tb);
        output data_valid;
        output data;
        output data_bytes;
        output sof;
        output eof;
        output block_tag;
    endclocking: cb
	
	clocking cb_rc@(posedge clock_rc);
	    input data_valid;
		input data;
		input data_bytes;
		input sof;
		input eof;
		input block_tag;
	endclocking: cb_rc
    
    modport inp(clocking cb,
                output rst_n,
                input clock_tb);
				
	modport inp_rc(clocking cb_rc,
	               input clock_rc);
				   
endinterface: eth_if_in

interface eth_if_sw(input  bit clock);
    logic           sw_data_valid;
    logic [63:0]    sw_data;
    logic [2:0]     sw_data_bytes;
    logic           sw_sof;
    logic           sw_eof;
    logic [9:0]     sw_block_tag;
    
    clocking cb@(posedge clock);
        input sw_block_tag;
        input sw_data;
        input sw_data_bytes;
        input sw_data_valid;
        input sw_eof;
        input sw_sof;
    endclocking: cb
    
    modport sw_out(clocking cb,
                   input clock);
endinterface: eth_if_sw

interface eth_if_cfig(input bit clock);
    logic [31:0]        upi_q;
    logic [31:0]        upi_d;
    logic [15:0]        upi_a;
    logic               upi_we;
    logic               upi_rd;
    logic               rst_n;
    
    clocking cb@(posedge clock);
        input  upi_q;
        output upi_d;
        output upi_a;
        output upi_we;
        output upi_rd;
    endclocking: cb
    
    modport cfig_tb(clocking cb,
                    input clock,
                    output rst_n);
endinterface: eth_if_cfig