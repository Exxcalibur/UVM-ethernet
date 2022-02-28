`ifndef GD_ETH_PACKET
`define GD_ETH_PACKET
//`include "uvm_macros.svh"
//import uvm_pkg::*;

typedef enum{GOOD_CRC, BAD_CRC} crc_kind;

class eth_packet extends uvm_sequence_item;
    rand bit   [47:0]           mac_dest        ;
	rand bit   [47:0]           mac_sour        ;
	rand bit   [15:0]           length          ;
	rand byte                   payload    []   ;
	rand bit   [31:0]           crc             ;
    
    rand crc_kind               crc_ok          ;

	constraint c_payload_size {payload.size inside {[46:1500]};}
	constraint c_length {length==payload.size;}
	
	`uvm_object_utils_begin(eth_packet)
	    `uvm_field_int           (mac_dest, UVM_DEFAULT)
		`uvm_field_int           (mac_sour,UVM_DEFAULT)
		`uvm_field_int           (length, UVM_DEFAULT)
		`uvm_field_array_int     (payload, UVM_DEFAULT)
		`uvm_field_int           (crc, UVM_DEFAULT)
        `uvm_field_enum          (crc_kind, crc_ok, UVM_ALL_ON|UVM_NOPACK)
	`uvm_object_utils_end
	
    extern function void post_randomize();
    
	function new(string name="eth_packet");
	    super.new(name);
	endfunction: new
endclass: eth_packet

function void eth_packet::post_randomize();
begin
    logic [31:0] poly=32'h04c1_1db7;
    logic [31:0] old_crc=32'hffff_ffff;
    logic [31:0] new_crc;
    byte head[14]={mac_dest[47:40], mac_dest[39:32],
                   mac_dest[31:24], mac_dest[23:16],
                   mac_dest[15:8],  mac_dest[7:0],
                   mac_sour[47:40], mac_sour[39:32],
                   mac_sour[31:24], mac_sour[23:16],
                   mac_sour[15:8],  mac_sour[7:0],
                   length[15:8],    length[7:0]};
    
    if(crc_ok==GOOD_CRC)
    begin
        for(int i=0;i<=13;i++)
        begin
            for(int j=0;j<=7;j++)
            begin
                if(old_crc[31]!=1'b0)
                begin
                    new_crc={old_crc[30:0],1'b0}^poly;
                    //old_crc=new_crc;
                end
                else
                    new_crc={old_crc[30:0],1'b0};
                    
                old_crc=new_crc;
                if(head[i][j]!=0)
                    new_crc=old_crc^poly;
                    
                old_crc=new_crc;
            end
        end
        
        for(int i=0;i<payload.size;i++)
        begin
            for(int j=0;j<=7;j++)
            begin
                if(old_crc[31]!=1'b0)
                begin
                    new_crc={old_crc[30:0],1'b0}^poly;
                    //old_crc=new_crc;
                end
                else
                    new_crc={old_crc[30:0],1'b0};
                    
                old_crc=new_crc;
                if(payload[i][j]!=0)
                    new_crc=old_crc^poly;
                    
                old_crc=new_crc;
            end
            
        end
        
        new_crc=new_crc^32'hffff_ffff;
        new_crc[31:24]={new_crc[24],new_crc[25],new_crc[26],new_crc[27],
                        new_crc[28],new_crc[29],new_crc[30],new_crc[31]};
        new_crc[23:16]={new_crc[16],new_crc[17],new_crc[18],new_crc[19],
                        new_crc[20],new_crc[21],new_crc[22],new_crc[23]};
        new_crc[15:8]={new_crc[8],new_crc[9],new_crc[10],new_crc[11],
                        new_crc[12],new_crc[13],new_crc[14],new_crc[15]};
        new_crc[7:0]={new_crc[0],new_crc[1],new_crc[2],new_crc[3],
                        new_crc[4],new_crc[5],new_crc[6],new_crc[7]};
            
        crc=new_crc;    
    end
end
endfunction
`endif