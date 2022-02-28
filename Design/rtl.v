//=====================================================================
// Project : ethernet switch
// File Name : cfig_ctrl.v
// Description : configuration controller. controll read and write action in config.
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================/
module cfig_ctrl(
    input sw_valid,
    input [15:0] upi_a,
    input upi_we,
    input upi_rd,
    output reg cp_wr,       //cross point
    output reg cp_rd,
    output reg mr_wr,      // mode reg
    output reg mr_rd,
    output reg dr_rd,        //discard reg
    output reg [3:0] dc_rd,        //discard counter
    output reg [3:0] cc_rd,        //correct counter
    output reg br_rd,       // busy reg
    output reg er_rd,        // error reg
    output reg [5:0] if_addr,     // logic table
    output reg [3:0] if_wr,
    output reg [3:0] if_rd
    );

    always@(upi_a or upi_rd or upi_we or sw_valid)
        begin
                  cp_wr=1'b0;
                  cp_rd=1'b0;
                  mr_wr=1'b0;
                  mr_rd=1'b0;
                  dr_rd=1'b0;
                  br_rd=1'b0;
                  er_rd=1'b0;
                  dc_rd=4'b0;
                  cc_rd=4'b0;
                  if_addr=6'b0;
                  if_wr=4'b0;
                  if_rd=4'b0;
            if(upi_a==16'h8001)   // cross point
                begin
                    cp_rd=upi_rd;
                    if(sw_valid==1'b0)
                    cp_wr=upi_we;
                end
            else if(upi_a==16'h8002||upi_a==16'h8003||upi_a==16'h8004||upi_a==16'h8005)   //discard counter
                begin
                    if(upi_rd==1'b1)
                    case(upi_a)
                        16'h8002: dc_rd=4'b0001;
                        16'h8003: dc_rd=4'b0010;
                        16'h8004: dc_rd=4'b0100;
                        16'h8005: dc_rd=4'b1000;
                        default: dc_rd=4'b0001;
                    endcase
                 end
            else if(upi_a==16'h8006||upi_a==16'h8007||upi_a==16'h8008||upi_a==16'h8009)   //correct counter
                begin
                    if(upi_rd==1'b1)
                    case(upi_a)
                        16'h8006: cc_rd=4'b0001;
                        16'h8007: cc_rd=4'b0010;
                        16'h8008: cc_rd=4'b0100;
                        16'h8009: cc_rd=4'b1000;
                        default: cc_rd=4'b0001;
                    endcase
                 end
           else if(upi_a==16'h800a)     //discard reg
               dr_rd=upi_rd;
           else if(upi_a==16'h800b)      //error reg
               er_rd=upi_rd;
           else if(upi_a==16'h800c)     //busy reg
               br_rd=upi_rd; 
           else if(upi_a==16'h800d)    // mode reg
               begin
               mr_rd=upi_rd;
               if(sw_valid==1'b0)
                   mr_wr=upi_we;
               end
           else if(upi_a[15:8]==8'h40&&upi_a[7:0]<=8'h3f)  // logic 32 table
               begin
                   if_addr=upi_a[5:0];
                   if_rd={4{upi_rd}};
                   if(sw_valid==1'b0)
                   if_wr={4{upi_we}};
                   
               end
 
      end     
  
endmodule




//=====================================================================
// Project : ethernet switch
// File Name : clk.v
// Description : clk generation, divide input frequency by 2
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module clk(
  input clk_ge,
  input clk_fe,
  input rst_n,
  output reg clk_ge2,
  output reg clk_fe2 
);

reg ge_q_b;
reg fe_q_b;
wire ge_d;
wire fe_d;

assign ge_d=ge_q_b;
assign fe_d=fe_q_b;

always@(posedge clk_ge or negedge rst_n)
begin
  if(rst_n==1'b0)
    begin
      clk_ge2<=1'b0;
      ge_q_b<=1'b1;
    end
  else 
    begin
      clk_ge2<=ge_d;
      ge_q_b<=~ge_d;
    end
end

always@(posedge clk_fe or negedge rst_n)
begin
  if(rst_n==1'b0)
    begin
      clk_fe2<=1'b0;
      fe_q_b<=1'b1;
    end
  else 
    begin
      clk_fe2<=fe_d;
      fe_q_b<=~fe_d;
    end
end

endmodule





//=====================================================================
// Project : ethernet switch
// File Name : confi.v
// Description : configuration component
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================/

// notes: separate if_rd address and if_wr address output:  lines  335


module confi(
    input [3:0] sw_valid,
    input [15:0] upi_a,
    input upi_we,
    input upi_rd,
    input clk_upi,
    input clk_ge,
    input clk_fe,
    input rst_upi_n,
    input rst_n_ge,
    input rst_n_fe,
    input [31:0] upi_d,

    input  [1:0] loss_0_ge,
    input  [1:0] loss_1_ge,
    input  [1:0] loss_2_ge,
    input  [1:0] loss_3_ge,
    input  [1:0] loss_0_fe,
    input  [1:0] loss_1_fe,
    input  [1:0] loss_2_fe,
    input  [1:0] loss_3_fe,
    
    input  [1:0] error_0_ge,
    input  [1:0] error_1_ge,
    input  [1:0] error_2_ge,
    input  [1:0] error_3_ge,
    input  [1:0] error_0_fe,
    input  [1:0] error_1_fe,
    input  [1:0] error_2_fe,
    input  [1:0] error_3_fe,
    
    input  [1:0] last_0_ge,
    input  [1:0] last_1_ge,
    input  [1:0] last_2_ge,
    input  [1:0] last_3_ge,
    input  [1:0] last_0_fe,
    input  [1:0] last_1_fe,
    input  [1:0] last_2_fe,
    input  [1:0] last_3_fe,
    
    input  [1:0] valid_0_ge,
    input  [1:0] valid_1_ge,
    input  [1:0] valid_2_ge,
    input  [1:0] valid_3_ge,
    input  [1:0] valid_0_fe,
    input  [1:0] valid_1_fe,
    input  [1:0] valid_2_fe,
    input  [1:0] valid_3_fe,

    input [31:0] con_data_in,    //if data output
    output [31:0] con_data_out,
    output [31:0] upi_q,
    output [5:0] if_addr_upi,
    output [5:0] if_addr_upi_wr,
    output [1:0] if_wr_g,
    output [1:0] if_wr_f,
    output [1:0] if_rd_g,
    output [1:0] if_rd_f,
    output [1:0] cp_0,
    output [1:0] cp_1,
    output [1:0] cp_2,
    output [1:0] cp_3,
    output mode_ge,
    output mode_fe
    );

    reg [31:0] config_bus;
    wire cp_wr;       //cross point
    wire cp_rd;
    wire mr_wr;      // mode reg
    wire mr_rd;
    wire dr_rd;                //discard reg
    wire [3:0] dc_rd;        //discard counter
    wire [3:0] cc_rd;        //correct counter
    wire br_rd;       // busy reg
    wire er_rd; 
    reg disc;
    reg busy;
    reg err;
    reg mode;
    
    wire [31:0] dc_out;
    wire [31:0] cc_out;
    wire [31:0] cp_out;
    wire [5:0] if_addr_pre;
    wire [3:0] if_wr_pre;
    wire [3:0] if_rd_pre;

    wire [1:0] loss_t;
    wire [1:0] valid_t;
    wire [1:0] error_t;
    
    
    wire  loss_s;
    wire  valid_s;
    wire  error_s;
    wire  sw_valid_s;
    wire  loss_s_syn;
    wire  valid_s_syn;
    wire  error_s_syn;
    wire  sw_valid_s_syn;

   // reg [31:0] con_data_out_ud1_gd1;
    //reg [31:0] con_data_out_ud1_fd1;
    reg [31:0] con_data_out_ud1;
    //reg [5:0] if_addr_ud1_gd1;
    reg [5:0] if_addr_ud1_fd1;  
    reg [5:0] if_addr_ud1; 
    reg [5:0] if_addr_wr_ud1;
    reg [3:0] if_wr_ud1;
    reg [3:0] if_rd_ud1;
                                                          //control synchronizers
    synch synch_inst_wr_0(.rst_n(rst_n_ge),
                          .clk(clk_ge),
                          .data_a(if_wr_ud1[0]),
                          .data_s(if_wr_g[0]));
    synch synch_inst_wr_1(.rst_n(rst_n_ge),
                          .clk(clk_ge),
                          .data_a(if_wr_ud1[1]),
                          .data_s(if_wr_g[1]));
    synch synch_inst_wr_2(.rst_n(rst_n_fe),
                          .clk(clk_fe),
                          .data_a(if_wr_ud1[2]),
                          .data_s(if_wr_f[0]));
    synch synch_inst_wr_3(.rst_n(rst_n_fe),
                          .clk(clk_fe),
                          .data_a(if_wr_ud1[3]),
                          .data_s(if_wr_f[1]));            
                          
    synch synch_inst_mode_ge(.rst_n(rst_n_ge),
                          .clk(clk_ge),
                          .data_a(mode),
                          .data_s(mode_ge));
    synch synch_inst_mode_fe(.rst_n(rst_n_fe),
                          .clk(clk_fe),
                          .data_a(mode),
                          .data_s(mode_fe));                          
                          
                                                                 //synch reg input
    synch synch_inst_err(.rst_n(rst_upi_n),
                         .clk(clk_upi),
                         .data_a(error_s),
                         .data_s(error_s_syn));
    synch synch_inst_val(.rst_n(rst_upi_n),
                         .clk(clk_upi),
                         .data_a(valid_s),
                         .data_s(valid_s_syn));
    synch synch_inst_los(.rst_n(rst_upi_n),
                         .clk(clk_upi),
                         .data_a(loss_s),
                         .data_s(loss_s_syn));        
    synch synch_inst_sw_val(.rst_n(rst_upi_n),
                         .clk(clk_upi),
                         .data_a(sw_valid_s),
                         .data_s(sw_valid_s_syn));                         
    
    dis_cnt dis_cnt_inst(.rst_n(rst_upi_n), 
                        .rst_n_ge(rst_n_ge),
                        .rst_n_fe(rst_n_fe),
                        .loss_0_ge(loss_0_ge),
                        .loss_1_ge(loss_1_ge),
                        .loss_2_ge(loss_2_ge),
                        .loss_3_ge(loss_3_ge),
                        .loss_0_fe(loss_0_fe),
                        .loss_1_fe(loss_1_fe),
                        .loss_2_fe(loss_2_fe),
                        .loss_3_fe(loss_3_fe),                        
                        .clk_ge(clk_ge), 
                        .clk_fe(clk_fe),     //discard counter
                        .clk_upi(clk_upi),                        
                        .dc_rd(dc_rd), 
                        .cnt_out(dc_out) );

    cor_cnt cor_cnt_inst(.rst_n(rst_upi_n), 
                        .rst_n_ge(rst_n_ge),
                        .rst_n_fe(rst_n_fe),
                        .error_0_ge(error_0_ge),
                        .error_1_ge(error_1_ge),
                        .error_2_ge(error_2_ge),
                        .error_3_ge(error_3_ge),
                        .error_0_fe(error_0_fe),
                        .error_1_fe(error_1_fe),
                        .error_2_fe(error_2_fe),
                        .error_3_fe(error_3_fe),               
                        .clk_ge(clk_ge), 
                        .clk_fe(clk_fe),                     
                        .clk_upi(clk_upi), 
                        .last_0_ge(last_0_ge),
                        .last_1_ge(last_1_ge),
                        .last_2_ge(last_2_ge),
                        .last_3_ge(last_3_ge),
                        .last_0_fe(last_0_fe),
                        .last_1_fe(last_1_fe),
                        .last_2_fe(last_2_fe),
                        .last_3_fe(last_3_fe), 
                        .cc_rd(cc_rd), 
                        .cnt_out(cc_out), 
                        .valid_0_ge(valid_0_ge),
                        .valid_1_ge(valid_1_ge),
                        .valid_2_ge(valid_2_ge),
                        .valid_3_ge(valid_3_ge),
                        .valid_0_fe(valid_0_fe),
                        .valid_1_fe(valid_1_fe),
                        .valid_2_fe(valid_2_fe),
                        .valid_3_fe(valid_3_fe) );  // correct counter

    cross_point cross_point_inst(.wr(cp_wr), 
                                .rd(cp_rd), 
                                .data(config_bus[7:0]), 
                                .data_out(cp_out), 
                                .clk_upi(clk_upi),                         
                                .rst_n(rst_upi_n), 
                                .cp_0(cp_0), 
                                .cp_1(cp_1), 
                                .cp_2(cp_2), 
                                .cp_3(cp_3));

    cfig_ctrl cfig_ctrl_inst(.sw_valid(sw_valid_s_syn), 
                            .upi_a(upi_a), 
                            .upi_we(upi_we), 
                            .upi_rd(upi_rd),    //control
                            .cp_wr(cp_wr), 
                            .cp_rd(cp_rd), 
                            .mr_wr(mr_wr), 
                            .mr_rd(mr_rd), 
                            .dr_rd(dr_rd), 
                            .dc_rd(dc_rd), 
                            .cc_rd(cc_rd), 
                            .br_rd(br_rd), 
                            .er_rd(er_rd), 
                            .if_addr(if_addr_pre), 
                            .if_wr(if_wr_pre), 
                            .if_rd(if_rd_pre) );

    assign upi_q=config_bus;
    assign if_addr_upi=if_addr_ud1;
    assign if_addr_upi_wr=if_addr_wr_ud1;
    assign con_data_out=con_data_out_ud1;
    assign if_rd_g=if_rd_ud1[1:0];
    assign if_rd_f=if_rd_ud1[3:2];
    assign loss_t=loss_0_ge|loss_1_ge|loss_2_ge|loss_3_ge|loss_0_fe|loss_1_fe|loss_2_fe|loss_3_fe;
    assign error_t=error_0_ge|error_1_ge|error_2_ge|error_3_ge|error_0_fe|error_1_fe|error_2_fe|error_3_fe;
    assign valid_t=valid_0_ge|valid_1_ge|valid_2_ge|valid_3_ge|valid_0_fe|valid_1_fe|valid_2_fe|valid_3_fe;
    assign loss_s=|loss_t;
    assign valid_s=|valid_t;
    assign error_s=|error_t;
    assign sw_valid_s=|sw_valid;

  always@(*)           // drive config_bus
      begin
          config_bus=32'b0;
          if(cp_rd==1'b1)
              config_bus=cp_out;
          else if(mr_rd==1'b1)
              config_bus[0]=mode;
          else if(dr_rd==1'b1)
              config_bus[0]=disc;
          else if(br_rd==1'b1)
              config_bus[0]=busy;
          else if(er_rd==1'b1)
              config_bus[0]=err;
          else if(dc_rd!=4'b0000)
              config_bus=dc_out;
          else if(cc_rd!=4'b0000)
              config_bus=cc_out;
          else if(if_rd_pre!=4'b0000)
              config_bus=con_data_in;
          else if(upi_we==1'b1)
              config_bus=upi_d;
       end
/*
   always@(posedge clk_ge or negedge rst_n_ge)             //output to sw dff buffer
   begin
       if(rst_n_ge==1'b0)
       begin
           con_data_out_ud1_gd1<=32'b0;
           con_data_out_g<=32'b0;
           if_addr_g<=6'b0;
           if_addr_ud1_gd1<=6'b0;
       end
       else 
       begin
           con_data_out_ud1_gd1<=con_data_out_ud1;
           con_data_out_g<=con_data_out_ud1_gd1;
           if_addr_g<=if_addr_ud1_gd1;
           if_addr_ud1_gd1<=if_addr_ud1;
       end
   end

   always@(posedge clk_fe or negedge rst_n_fe)             //output to sw dff buffer
   begin
       if(rst_n_fe==1'b0)
       begin
           con_data_out_ud1_fd1<=32'b0;
           con_data_out_f<=32'b0;
           if_addr_f<=6'b0;
           if_addr_ud1_fd1<=6'b0;
       end
       else 
       begin
           con_data_out_ud1_fd1<=con_data_out_ud1;
           con_data_out_f<=con_data_out_ud1_fd1;
           if_addr_f<=if_addr_ud1_fd1;
           if_addr_ud1_fd1<=if_addr_ud1;
       end
   end
   */
   always@(posedge clk_upi or negedge rst_upi_n)         //clk_upi sample
   begin
       if(rst_upi_n==1'b0)
       begin
           con_data_out_ud1<=32'b0;
           if_addr_ud1<=6'b0;
           if_rd_ud1<=4'b0;
           if_wr_ud1<=4'b0;
       end
       else
       begin
           if(if_wr_pre!=4'b0)
           begin
           con_data_out_ud1<=config_bus;
           if_addr_wr_ud1<=if_addr_pre;                            
           end
           if_addr_ud1<=if_addr_pre; 
           if_rd_ud1<=if_rd_pre;
           if_wr_ud1<=if_wr_pre;
       end
   end
   
  always@(posedge clk_upi or negedge rst_upi_n)           //reg update
      if(rst_upi_n==1'b0)
      begin
        disc<=1'b0;
        busy<=1'b0;
        err<=1'b0;
        mode<=1'b0;
      end
      else
      begin
          if(loss_s_syn)
              disc<=1'b1;
          else
              disc<=1'b0;

          if(valid_s_syn)
              busy<=1'b1;
          else
              busy<=1'b0;

          if(error_s_syn)
              err<=1'b1;
          else err<=1'b0;

          if(mr_wr==1'b1)
              mode<=config_bus[0];
      end





endmodule














//=====================================================================
// Project : ethernet switch
// File Name : cor_cnt.v
// Description : correct number counter, counting the number of correct received packets
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================/
module cor_cnt(
    input rst_n,
    input rst_n_ge,
    input rst_n_fe,
    input clk_ge,
    input clk_fe,
    input clk_upi,
    
    input  [1:0] error_0_ge,
    input  [1:0] error_1_ge,
    input  [1:0] error_2_ge,
    input  [1:0] error_3_ge,
    input  [1:0] error_0_fe,
    input  [1:0] error_1_fe,
    input  [1:0] error_2_fe,
    input  [1:0] error_3_fe,
    
    input  [1:0] last_0_ge,
    input  [1:0] last_1_ge,
    input  [1:0] last_2_ge,
    input  [1:0] last_3_ge,
    input  [1:0] last_0_fe,
    input  [1:0] last_1_fe,
    input  [1:0] last_2_fe,
    input  [1:0] last_3_fe,
    
    input  [1:0] valid_0_ge,
    input  [1:0] valid_1_ge,
    input  [1:0] valid_2_ge,
    input  [1:0] valid_3_ge,
    input  [1:0] valid_0_fe,
    input  [1:0] valid_1_fe,
    input  [1:0] valid_2_fe,
    input  [1:0] valid_3_fe,
    
    input [3:0] cc_rd,
    output reg [31:0] cnt_out
    );

    reg [31:0] cnt [3:0];
    
    wire error_0_t_ge;
    wire error_1_t_ge;
    wire error_2_t_ge;
    wire error_3_t_ge;
    wire error_0_t_ge_syn;
    wire error_1_t_ge_syn;
    wire error_2_t_ge_syn;
    wire error_3_t_ge_syn;
    wire error_0_t_fe;
    wire error_1_t_fe;
    wire error_2_t_fe;
    wire error_3_t_fe;
    wire error_0_t_fe_syn;
    wire error_1_t_fe_syn;
    wire error_2_t_fe_syn;
    wire error_3_t_fe_syn;
    
    wire cor_0_ge_0;
    wire cor_0_ge_1;
    wire cor_0_fe_0;
    wire cor_0_fe_1;
    wire cor_0_ge_0_syn;
    wire cor_0_ge_1_syn;
    wire cor_0_fe_0_syn;
    wire cor_0_fe_1_syn;
    
    wire cor_1_ge_0;
    wire cor_1_ge_1;
    wire cor_1_fe_0;
    wire cor_1_fe_1;
    wire cor_1_ge_0_syn;
    wire cor_1_ge_1_syn;
    wire cor_1_fe_0_syn;
    wire cor_1_fe_1_syn;
    
    wire cor_2_ge_0;
    wire cor_2_ge_1;
    wire cor_2_fe_0;
    wire cor_2_fe_1;
    wire cor_2_ge_0_syn;
    wire cor_2_ge_1_syn;
    wire cor_2_fe_0_syn;
    wire cor_2_fe_1_syn;
    
    wire cor_3_ge_0;
    wire cor_3_ge_1;
    wire cor_3_fe_0;
    wire cor_3_fe_1;
    wire cor_3_ge_0_syn;
    wire cor_3_ge_1_syn;
    wire cor_3_fe_0_syn;
    wire cor_3_fe_1_syn;
                                                                 //error synch
    pulse_synch pulse_synch_inst_0_err_ge(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_0_t_ge),
                       .data_s(error_0_t_ge_syn));
    pulse_synch pulse_synch_inst_0_err_fe(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_0_t_fe),
                       .data_s(error_0_t_fe_syn));    
                       
    pulse_synch pulse_synch_inst_1_err_ge(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_1_t_ge),
                       .data_s(error_1_t_ge_syn));
    pulse_synch pulse_synch_inst_1_err_fe(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_1_t_fe),
                       .data_s(error_1_t_fe_syn));

    pulse_synch pulse_synch_inst_2_err_ge(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_2_t_ge),
                       .data_s(error_2_t_ge_syn));
    pulse_synch pulse_synch_inst_2_err_fe(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_2_t_fe),
                       .data_s(error_2_t_fe_syn));

    pulse_synch pulse_synch_inst_3_err_ge(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_3_t_ge),
                       .data_s(error_3_t_ge_syn));
    pulse_synch pulse_synch_inst_3_err_fe(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(error_3_t_fe),
                       .data_s(error_3_t_fe_syn));                       
                                                          // correct synch
    pulse_synch pulse_synch_inst_0_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_0_ge_0),
                       .data_s(cor_0_ge_0_syn));
    pulse_synch pulse_synch_inst_0_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_0_ge_1),
                       .data_s(cor_0_ge_1_syn));                       
    pulse_synch pulse_synch_inst_0_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_0_fe_0),
                       .data_s(cor_0_fe_0_syn));
    pulse_synch pulse_synch_inst_0_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_0_fe_1),
                       .data_s(cor_0_fe_1_syn));

    pulse_synch pulse_synch_inst_1_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_1_ge_0),
                       .data_s(cor_1_ge_0_syn));
    pulse_synch pulse_synch_inst_1_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_1_ge_1),
                       .data_s(cor_1_ge_1_syn));                       
    pulse_synch pulse_synch_inst_1_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_1_fe_0),
                       .data_s(cor_1_fe_0_syn));
    pulse_synch pulse_synch_inst_1_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_1_fe_1),
                       .data_s(cor_1_fe_1_syn));    
                       
    pulse_synch pulse_synch_inst_2_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_2_ge_0),
                       .data_s(cor_2_ge_0_syn));
    pulse_synch pulse_synch_inst_2_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_2_ge_1),
                       .data_s(cor_2_ge_1_syn));                       
    pulse_synch pulse_synch_inst_2_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_2_fe_0),
                       .data_s(cor_2_fe_0_syn));
    pulse_synch pulse_synch_inst_2_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_2_fe_1),
                       .data_s(cor_2_fe_1_syn));

    pulse_synch pulse_synch_inst_3_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_3_ge_0),
                       .data_s(cor_3_ge_0_syn));
    pulse_synch pulse_synch_inst_3_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_3_ge_1),
                       .data_s(cor_3_ge_1_syn));                       
    pulse_synch pulse_synch_inst_3_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_3_fe_0),
                       .data_s(cor_3_fe_0_syn));
    pulse_synch pulse_synch_inst_3_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(cor_3_fe_1),
                       .data_s(cor_3_fe_1_syn));         
                                                                    // correct number each cycle on ge and fe port
    assign cor_0_ge_0=((!error_0_ge[0])&last_0_ge[0]&valid_0_ge[0]);
    assign cor_0_ge_1=((!error_0_ge[1])&last_0_ge[1]&valid_0_ge[1]);
    assign cor_0_fe_0=((!error_0_fe[0])&last_0_fe[0]&valid_0_fe[0]);
    assign cor_0_fe_1=((!error_0_fe[1])&last_0_fe[1]&valid_0_fe[1]);
    
    assign cor_1_ge_0=((!error_1_ge[0])&last_1_ge[0]&valid_1_ge[0]);
    assign cor_1_ge_1=((!error_1_ge[1])&last_1_ge[1]&valid_1_ge[1]);
    assign cor_1_fe_0=((!error_1_fe[0])&last_1_fe[0]&valid_1_fe[0]);
    assign cor_1_fe_1=((!error_1_fe[1])&last_1_fe[1]&valid_1_fe[1]);
    
    assign cor_2_ge_0=((!error_2_ge[0])&last_2_ge[0]&valid_2_ge[0]);
    assign cor_2_ge_1=((!error_2_ge[1])&last_2_ge[1]&valid_2_ge[1]);
    assign cor_2_fe_0=((!error_2_fe[0])&last_2_fe[0]&valid_2_fe[0]);
    assign cor_2_fe_1=((!error_2_fe[1])&last_2_fe[1]&valid_2_fe[1]);
    
    assign cor_3_ge_0=((!error_3_ge[0])&last_3_ge[0]&valid_3_ge[0]);
    assign cor_3_ge_1=((!error_3_ge[1])&last_3_ge[1]&valid_3_ge[1]);
    assign cor_3_fe_0=((!error_3_fe[0])&last_3_fe[0]&valid_3_fe[0]);
    assign cor_3_fe_1=((!error_3_fe[1])&last_3_fe[1]&valid_3_fe[1]);
    
    assign error_0_t_fe=|error_0_fe;
    assign error_0_t_ge=|error_0_ge;
    assign error_1_t_fe=|error_1_fe;
    assign error_1_t_ge=|error_1_ge;
    assign error_2_t_fe=|error_2_fe;
    assign error_2_t_ge=|error_2_ge;
    assign error_3_t_fe=|error_3_fe;
    assign error_3_t_ge=|error_3_ge;

                      

    always@(posedge clk_upi or negedge rst_n) 
    begin
        if(rst_n==1'b0)
        begin
            cnt[0]<=32'b0;
            cnt[1]<=32'b0;
            cnt[2]<=32'b0;
            cnt[3]<=32'b0;
        end
        else
        begin
            if(error_0_t_ge_syn||error_0_t_fe_syn)
                cnt[0]<=32'b0;
            else
                cnt[0]<=cnt[0]+cor_0_ge_0_syn+cor_0_ge_1_syn+cor_0_fe_0_syn+cor_0_fe_1_syn;
                
            if(error_1_t_ge_syn||error_1_t_fe_syn)
                cnt[1]<=32'b0;
            else
                cnt[1]<=cnt[1]+cor_1_ge_0_syn+cor_1_ge_1_syn+cor_1_fe_0_syn+cor_1_fe_1_syn;
                
            if(error_2_t_ge_syn||error_2_t_fe_syn)
                cnt[2]<=32'b0;
            else
                cnt[2]<=cnt[2]+cor_2_ge_0_syn+cor_2_ge_1_syn+cor_2_fe_0_syn+cor_2_fe_1_syn;
                
            if(error_3_t_ge_syn||error_3_t_fe_syn)
                cnt[3]<=32'b0;                
            else
                cnt[3]<=cnt[3]+cor_3_ge_0_syn+cor_3_ge_1_syn+cor_3_fe_0_syn+cor_3_fe_1_syn;
        end

    end
    
    always@(posedge clk_upi or negedge rst_n)                               //counter output
        begin
            if(rst_n==1'b0)
            begin
                cnt_out<=32'b0;
            end
            else 
                begin
                case(cc_rd)
                    4'b0000: cnt_out<=32'b0;
                    4'b0001: begin 
                                      cnt_out<=cnt[0]; 
                                  end
                    4'b0010: begin 
                                      cnt_out<=cnt[1]; 
                                  end
                    4'b0100: begin 
                                      cnt_out<=cnt[2]; 
                                  end
                    4'b1000: begin 
                                      cnt_out<=cnt[3]; 
                                  end
                    default: cnt_out<=32'b0;
                    endcase
                end
           end
endmodule






//=====================================================================
// Project : ethernet switch
// File Name : crc32.v
// Description : crc_res32 algorithm for 128 bits data input
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module crc32( 
    input clk,
    input [127:0] data,
    input first,
    input last,
    input valid,
    input [3:0] bytes,
    input rst_n,
    output reg error            
);

    reg [31:0] mux0;                  //  mux for output
    reg [31:0] mux1;                   //mux for first group input
    reg [31:0] mux0_in;
    wire [31:0] crc_res[15:0];          //all 8 bit crc result

    parameter crc_int=32'hffff_ffff, 
              crc_good=32'hc704_dd7b;

    crc32_d8 cd8_ins0(.crc(mux0),                        // first 8 bit crc
                      .data(data[127:120]),
                      .crc_out(crc_res[0]));
    genvar j;
    generate
    for(j=1;j<=15;j=j+1)                                 // rest 8 bit crc
      begin: crc32_d8_loop
      crc32_d8 cd8_ins(.crc(crc_res[j-1]),
                       .data(data[127-8*j:120-8*j]),
                       .crc_out(crc_res[j]));
      end
    endgenerate

    always@(posedge clk or negedge rst_n)   //DFF
    begin
        if(rst_n==1'b0)
            mux0_in<=32'b0;
        else
            mux0_in<=crc_res[15];
    end

    always@(mux0_in or first)   //mux0
    begin
      case(first)
      1'b0: mux0=mux0_in;
      1'b1: mux0=crc_int;
      endcase
    end

    always@(*)      //mux1
    begin
      case(bytes)
      4'd0: mux1=crc_res[0];
      4'd1: mux1=crc_res[1];
      4'd2: mux1=crc_res[2];
      4'd3: mux1=crc_res[3];
      4'd4: mux1=crc_res[4];
      4'd5: mux1=crc_res[5];
      4'd6: mux1=crc_res[6];
      4'd7: mux1=crc_res[7];
      4'd8: mux1=crc_res[8];
      4'd9: mux1=crc_res[9];
      4'd10: mux1=crc_res[10];
      4'd11: mux1=crc_res[11];
      4'd12: mux1=crc_res[12];
      4'd13: mux1=crc_res[13];
      4'd14: mux1=crc_res[14];
      4'd15: mux1=crc_res[15];
      default: mux1=crc_res[0];
      endcase
    end

    always@(posedge clk or negedge rst_n)      //check good value
    begin
        if(rst_n==1'b0)
            error<=1'b0;
       else if((valid==1)&&(last==1)&&(mux1!=crc_good))
           error<=1'b1;
       else
           error<=1'b0;
    end

endmodule





//=====================================================================
// Project : ethernet switch
// File Name : crc32_d8.v
// Description : CRC32 algorithm for 8bits data input
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================//
//                                                --
// POLY             : 0 1 2 4 5 7 8 10 11 12 16 22 23 26 32
// DATA_WIDTH       : 8
// BIT_ORDER        : low
// SHIFT_DIRECTION  : left
// LFSR_TYPE        : 0
//                                                --
 module crc32_d8(
 input [31:0] crc,
 input [7:0] data,
 output [31:0] crc_out
);

  //reg [31:0] c;
  //reg [7:0] d;
  reg [31:0] new_crc;
  
  assign crc_out=new_crc;

  always@(crc or data)   //calculate crc for 8 bits data
  begin
    //c = crc;
    //d = data;

    new_crc[0] = crc[24]^crc[30]^data[1]^data[7];
    new_crc[1] = crc[24]^crc[25]^crc[30]^crc[31]^data[0]^data[1]^data[6]^data[7];
    new_crc[2] = crc[24]^crc[25]^crc[26]^crc[30]^crc[31]^data[0]^data[1]^data[5]^
                 data[6]^data[7];
    new_crc[3] = crc[25]^crc[26]^crc[27]^crc[31]^data[0]^data[4]^data[5]^data[6];
    new_crc[4] = crc[24]^crc[26]^crc[27]^crc[28]^crc[30]^data[1]^data[3]^data[4]^
                 data[5]^data[7];
    new_crc[5] = crc[24]^crc[25]^crc[27]^crc[28]^crc[29]^crc[30]^crc[31]^data[0]^
                 data[1]^data[2]^data[3]^data[4]^data[6]^data[7];
    new_crc[6] = crc[25]^crc[26]^crc[28]^crc[29]^crc[30]^crc[31]^data[0]^data[1]^
                 data[2]^data[3]^data[5]^data[6];
    new_crc[7] = crc[24]^crc[26]^crc[27]^crc[29]^crc[31]^data[0]^data[2]^data[4]^
                 data[5]^data[7];
    new_crc[8] = crc[0]^crc[24]^crc[25]^crc[27]^crc[28]^data[3]^data[4]^data[6]^
                 data[7];
    new_crc[9] = crc[1]^crc[25]^crc[26]^crc[28]^crc[29]^data[2]^data[3]^data[5]^
                 data[6];
    new_crc[10] = crc[24]^crc[26]^crc[27]^crc[29]^crc[2]^data[2]^data[4]^data[5]^
                  data[7];
    new_crc[11] = crc[24]^crc[25]^crc[27]^crc[28]^crc[3]^data[3]^data[4]^data[6]^
                  data[7];
    new_crc[12] = crc[24]^crc[25]^crc[26]^crc[28]^crc[29]^crc[30]^crc[4]^data[1]^
                  data[2]^data[3]^data[5]^data[6]^data[7];
    new_crc[13] = crc[25]^crc[26]^crc[27]^crc[29]^crc[30]^crc[31]^crc[5]^data[0]^
                  data[1]^data[2]^data[4]^data[5]^data[6];
    new_crc[14] = crc[26]^crc[27]^crc[28]^crc[30]^crc[31]^crc[6]^data[0]^data[1]^
                  data[3]^data[4]^data[5];
    new_crc[15] = crc[27]^crc[28]^crc[29]^crc[31]^crc[7]^data[0]^data[2]^data[3]^
                  data[4];
    new_crc[16] = crc[24]^crc[28]^crc[29]^crc[8]^data[2]^data[3]^data[7];
    new_crc[17] = crc[25]^crc[29]^crc[30]^crc[9]^data[1]^data[2]^data[6];
    new_crc[18] = crc[10]^crc[26]^crc[30]^crc[31]^data[0]^data[1]^data[5];
    new_crc[19] = crc[11]^crc[27]^crc[31]^data[0]^data[4];
    new_crc[20] = crc[12]^crc[28]^data[3];
    new_crc[21] = crc[13]^crc[29]^data[2];
    new_crc[22] = crc[14]^crc[24]^data[7];
    new_crc[23] = crc[15]^crc[24]^crc[25]^crc[30]^data[1]^data[6]^data[7];
    new_crc[24] = crc[16]^crc[25]^crc[26]^crc[31]^data[0]^data[5]^data[6];
    new_crc[25] = crc[17]^crc[26]^crc[27]^data[4]^data[5];
    new_crc[26] = crc[18]^crc[24]^crc[27]^crc[28]^crc[30]^data[1]^data[3]^data[4]^
                  data[7];
    new_crc[27] = crc[19]^crc[25]^crc[28]^crc[29]^crc[31]^data[0]^data[2]^data[3]^
                  data[6];
    new_crc[28] = crc[20]^crc[26]^crc[29]^crc[30]^data[1]^data[2]^data[5];
    new_crc[29] = crc[21]^crc[27]^crc[30]^crc[31]^data[0]^data[1]^data[4];
    new_crc[30] = crc[22]^crc[28]^crc[31]^data[0]^data[3];
    new_crc[31] = crc[23]^crc[29]^data[2];
    //crc_out = new_crc;

  end
endmodule




//=====================================================================
// Project : ethernet switch
// File Name : cross_point.v
// Description : cross point table
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module cross_point(
     input wr,
     input rd,
     input [7:0] data,
     input rst_n,
     input clk_upi,
     output [1:0] cp_0,
     output [1:0] cp_1,
     output [1:0] cp_2,
     output [1:0] cp_3,
     output reg [31:0] data_out
    );

    reg [1:0] memory[3:0];

    assign cp_0=memory[0];
    assign cp_1=memory[1];
    assign cp_2=memory[2];   
    assign cp_3=memory[3];

    always@(posedge clk_upi or negedge rst_n)
        begin
            if (rst_n==1'b0)        //reset
              begin
                  memory[3]<=2'b0;
                  memory[2]<=2'b0;
                  memory[1]<=2'b0;
                  memory[0]<=2'b0;
                  data_out<=32'b0;
               end
            else if(wr==1'b1&&rd==1'b0)  //write
              begin
                  memory[3]<=data[7:6];
                  memory[2]<=data[5:4];
                  memory[1]<=data[3:2];
                  memory[0]<=data[1:0];
                  data_out<=32'b0;
              end
            else if(wr==1'b0&&rd==1'b1)  //rd
                begin
                    data_out[31:8]<=24'b0;
                    data_out[7:0]<={memory[3],memory[2],memory[1],memory[0]};
                end
            else data_out<=32'b0;
         end

endmodule




//=====================================================================
// Project : ethernet switch
// File Name : dff_80.v
// Description : 80 bit input dff
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module dff_80(
    input [79:0]  din,
    input clk,
    input rst_n,
    output  reg [79:0] qout
    );

    always@(posedge clk or negedge rst_n)
        begin
            if(rst_n==1'b0)
                qout<=80'b0;
            else
                qout<=din;
         end

   endmodule




//=====================================================================
// Project : ethernet switch
// File Name : dis_cnt.v
// Description : discard counter, keeping track of the number of discared packet on each fifo port
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================/
module dis_cnt(
    input rst_n,
    input rst_n_ge,
    input rst_n_fe,
    input  [1:0] loss_0_ge,
    input  [1:0] loss_1_ge,
    input  [1:0] loss_2_ge,
    input  [1:0] loss_3_ge,
    input  [1:0] loss_0_fe,
    input  [1:0] loss_1_fe,
    input  [1:0] loss_2_fe,
    input  [1:0] loss_3_fe,
    input clk_ge,
    input clk_fe,
    input clk_upi,
    input [3:0] dc_rd,
    output reg [31:0] cnt_out
    );

    //reg [31:0] cnt_out;
    reg [31:0] cnt [3:0];
   // reg [31:0] ge_cnt [3:0];
    //reg [31:0] fe_cnt [3:0];
    //wire [1:0] ge_loss[3:0];
    //wire [1:0] fe_loss[3:0];
    
    wire loss_0_ge_syn_0;
    wire loss_0_ge_syn_1;
    wire loss_0_fe_syn_0;
    wire loss_0_fe_syn_1;
    
    wire loss_1_ge_syn_0;    
    wire loss_1_ge_syn_1;
    wire loss_1_fe_syn_0;
    wire loss_1_fe_syn_1;
    
    wire loss_2_ge_syn_0;    
    wire loss_2_ge_syn_1;
    wire loss_2_fe_syn_0;
    wire loss_2_fe_syn_1;

    wire loss_3_ge_syn_0;    
    wire loss_3_ge_syn_1;
    wire loss_3_fe_syn_0;
    wire loss_3_fe_syn_1;
    

    pulse_synch pulse_synch_inst_0_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_0_ge[0]),
                       .data_s(loss_0_ge_syn_0));
    pulse_synch pulse_synch_inst_0_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_0_ge[1]),
                       .data_s(loss_0_ge_syn_1));                       
    pulse_synch pulse_synch_inst_0_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_0_fe[0]),
                       .data_s(loss_0_fe_syn_0));
    pulse_synch pulse_synch_inst_0_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_0_fe[1]),
                       .data_s(loss_0_fe_syn_1));

    pulse_synch pulse_synch_inst_1_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_1_ge[0]),
                       .data_s(loss_1_ge_syn_0));
    pulse_synch pulse_synch_inst_1_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_1_ge[1]),
                       .data_s(loss_1_ge_syn_1));                       
    pulse_synch pulse_synch_inst_1_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_1_fe[0]),
                       .data_s(loss_1_fe_syn_0));
    pulse_synch pulse_synch_inst_1_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_1_fe[1]),
                       .data_s(loss_1_fe_syn_1));    
                       
    pulse_synch pulse_synch_inst_2_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_2_ge[0]),
                       .data_s(loss_2_ge_syn_0));
    pulse_synch pulse_synch_inst_2_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_2_ge[1]),
                       .data_s(loss_2_ge_syn_1));                       
    pulse_synch pulse_synch_inst_2_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_2_fe[0]),
                       .data_s(loss_2_fe_syn_0));
    pulse_synch pulse_synch_inst_2_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_2_fe[1]),
                       .data_s(loss_2_fe_syn_1));

    pulse_synch pulse_synch_inst_3_ge_0(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_3_ge[0]),
                       .data_s(loss_3_ge_syn_0));
    pulse_synch pulse_synch_inst_3_ge_1(
                       .rst_n_a(rst_n_ge),
                       .clk_a(clk_ge),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_3_ge[1]),
                       .data_s(loss_3_ge_syn_1));                       
    pulse_synch pulse_synch_inst_3_fe_0(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_3_fe[0]),
                       .data_s(loss_3_fe_syn_0));
    pulse_synch pulse_synch_inst_3_fe_1(
                       .rst_n_a(rst_n_fe),
                       .clk_a(clk_fe),
                       .rst_n_b(rst_n),
                       .clk_b(clk_upi),
                       .data_a(loss_3_fe[1]),
                       .data_s(loss_3_fe_syn_1));    

    always@(posedge clk_upi or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            cnt[0]<=32'b0;
            cnt[1]<=32'b0;
            cnt[2]<=32'b0;
            cnt[3]<=32'b0;            
        end
        else
        begin
            if(dc_rd!=4'b0001)
                cnt[0]<=cnt[0]+loss_0_fe_syn_0+loss_0_fe_syn_1+loss_0_ge_syn_0+loss_0_ge_syn_1;
			else
			    cnt[0]<=32'b0;
			if(dc_rd!=4'b0010)
                cnt[1]<=cnt[1]+loss_1_fe_syn_0+loss_1_fe_syn_1+loss_1_ge_syn_0+loss_1_ge_syn_1;
			else
			    cnt[1]<=32'b0;
			if(dc_rd!=4'b0100)
                cnt[2]<=cnt[2]+loss_2_fe_syn_0+loss_2_fe_syn_1+loss_2_ge_syn_0+loss_2_ge_syn_1;
			else
			    cnt[2]<=32'b0;
			if(dc_rd!=4'b1000)
                cnt[3]<=cnt[3]+loss_3_fe_syn_0+loss_3_fe_syn_1+loss_3_ge_syn_0+loss_3_ge_syn_1;
			else
			    cnt[3]<=32'b0;
        end
    end    
                       
    always@(posedge clk_upi or negedge rst_n)
        begin
            if(rst_n==1'b0)
                begin
                cnt_out<=32'b0;
                end
            else 
                begin
                case(dc_rd)
                    4'b0000: begin
                             cnt_out<=32'b0;
                             end
                    4'b0001: begin 
                             cnt_out<=cnt[0];
                             end
                    4'b0010: begin 
                             cnt_out<=cnt[1];
                             end
                    4'b0100: begin 
                             cnt_out<=cnt[2];
                             end
                    4'b1000: begin 
                             cnt_out<=cnt[3];
                             end
                    default: begin
                             cnt_out<=32'b0;
                             end
                    endcase
                end
           end
endmodule










//=====================================================================
// Project : ethernet switch
// File Name : fifo.v
// Description : fifo component, including 4 mem
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module fifo#(
    parameter pt_wd=9,
    parameter sp_dp=512
    )(
    input clk_fe_wr,
    input clk_ge_wr,
    input clk_rd,
    input rst_n_ge_w,
    input rst_n_fe_w,
    input rst_n_r,
    input [3:0] crc_err,
    input [79:0] pkt0_0,
    input [79:0] pkt1_0,
    input [79:0] pkt0_1,
    input [79:0] pkt1_1,
    input [79:0] pkt0_2,
    input [79:0] pkt1_2,
    input [79:0] pkt0_3,
    input [79:0] pkt1_3,
    output [1:0] last_ge,
    output [1:0] last_fe,
    output [1:0] loss_ge,
    output [1:0] loss_fe,
    output [1:0] error_ge,
    output [1:0] error_fe,
    output [1:0] valid_ge,
    output [1:0] valid_fe,
    
    output switched_data_valid,
    output [63:0] switched_data,
    output [2:0] switched_data_bytes,
    output switched_sof,
    output switched_eof,
    output [9:0] switched_block_tag);
    
    wire [3:0] rd_end;    // mem readout eof signal
    wire [3:0] disc;
    wire [3:0] rd;    //mem read enable
    wire [3:0] wr;    //mem write enable
    wire [pt_wd:0] left_0;
    wire [pt_wd:0] left_1;
    wire [9:0] left_2;
    wire [9:0] left_3;
    wire [20:0] f_in_0;
    wire [20:0] f_in_1;
    wire [20:0] f_in_2;
    wire [20:0] f_in_3;
    wire [79:0] pkt [3:0];    // mem output
    reg [79:0] mux_out;
    reg [3:0] rd_d1;
    wire [3:0] peek_last;
   // reg [3:0] mux_eof;
    //reg [3:0]
    
    assign f_in_0={pkt0_0[79],pkt1_0[79],pkt0_0[11],pkt0_0[10],pkt1_0[10],pkt1_0[46:31]};
    assign f_in_1={pkt0_1[79],pkt1_1[79],pkt0_1[11],pkt0_1[10],pkt1_1[10],pkt1_1[46:31]};
    assign f_in_2={pkt0_2[79],pkt1_2[79],pkt0_2[11],pkt0_2[10],pkt1_2[10],pkt1_2[46:31]};
    assign f_in_3={pkt0_3[79],pkt1_3[79],pkt0_3[11],pkt0_3[10],pkt1_3[10],pkt1_3[46:31]};

    assign rd_end[0]=pkt[0][10]&pkt[0][79];
    assign rd_end[1]=pkt[1][10]&pkt[1][79];
    assign rd_end[2]=pkt[2][10]&pkt[2][79];
    assign rd_end[3]=pkt[3][10]&pkt[3][79];
    
    assign switched_data_valid=mux_out[79];    // split output to individual signals
    assign switched_data=mux_out[78:15];
    assign switched_data_bytes=mux_out[14:12];
    assign switched_sof=mux_out[11];
    assign switched_eof=mux_out[10];
    assign switched_block_tag=mux_out[9:0];
    
    fifo_ctrl #(.pt_wd(pt_wd))  fc_inst(.clk_fe_wr(clk_fe_wr), 
                                                                             .clk_ge_wr(clk_ge_wr), 
                                                                             .clk_rd(clk_rd), 
                                                                             .left_0(left_0), 
                                                                             .left_1(left_1), 
                                                                             .left_2(left_2), 
                                                                             .left_3(left_3),
                                                                             .f_in_0(f_in_0), 
                                                                             .f_in_1(f_in_1), 
                                                                             .f_in_2(f_in_2), 
                                                                             .f_in_3(f_in_3), 
                                                                             .rd_end(rd_end), 
                                                                             .crc_err(crc_err), 
                                                                             .rst_n_ge_w(rst_n_ge_w),
                                                                             .rst_n_fe_w(rst_n_fe_w),
                                                                             .rst_n_r(rst_n_r),
                                                                             .disc(disc), 
                                                                             .wr(wr), 
                                                                             .rd(rd),
                                                                             .last_ge(last_ge),
                                                                             .last_fe(last_fe),
                                                                             .loss_ge(loss_ge),                                                                             
                                                                             .loss_fe(loss_fe), 
                                                                             .error_ge(error_ge),
                                                                             .error_fe(error_fe),
                                                                             .valid_ge(valid_ge),
                                                                             .valid_fe(valid_fe),
                                                                             .peek_last(peek_last));
                      
    mem #(.depth(sp_dp),.pt_wd(pt_wd)) mem_inst_0 (.pkt0(pkt0_0), 
                                                                               .pkt1(pkt1_0), 
                                                                               .rd(rd[0]), 
                                                                               .wr(wr[0]), 
                                                                               .clk_r(clk_rd),
                                                                               .clk_w(clk_ge_wr), 
                                                                               .rst_n_w(rst_n_ge_w),
                                                                               .rst_n_r(rst_n_r) ,
                                                                               .disc(disc[0]), 
                                                                               .pkt(pkt[0]), 
                                                                               .left(left_0),
                                                                               .peek_last(peek_last[0]));    
        
    mem #(.depth(sp_dp),.pt_wd(pt_wd)) mem_inst_1 (.pkt0(pkt0_1), 
                                                                               .pkt1(pkt1_1), 
                                                                               .rd(rd[1]), 
                                                                               .wr(wr[1]), 
                                                                               .clk_r(clk_rd),
                                                                               .clk_w(clk_ge_wr), 
                                                                               .rst_n_w(rst_n_ge_w),
                                                                               .rst_n_r(rst_n_r) , 
                                                                               .disc(disc[1]), 
                                                                               .pkt(pkt[1]), 
                                                                               .left(left_1),
                                                                               .peek_last(peek_last[1]));    
        
    
    mem mem_inst_2  (.pkt0(pkt0_2), 
                                 .pkt1(pkt1_2), 
                                 .rd(rd[2]), 
                                 .wr(wr[2]), 
                                 .clk_r(clk_rd),
                                 .clk_w(clk_fe_wr), 
                                 .rst_n_w(rst_n_fe_w),
                                 .rst_n_r(rst_n_r) , 
                                 .disc(disc[2]), 
                                 .pkt(pkt[2]), 
                                 .left(left_2),
                                 .peek_last(peek_last[2]));

    mem mem_inst_3  (.pkt0(pkt0_3), 
                                 .pkt1(pkt1_3), 
                                 .rd(rd[3]), 
                                 .wr(wr[3]), 
                                 .clk_r(clk_rd),
                                 .clk_w(clk_fe_wr), 
                                 .rst_n_w(rst_n_fe_w),
                                 .rst_n_r(rst_n_r) ,
                                 .disc(disc[3]), 
                                 .pkt(pkt[3]), 
                                 .left(left_3),
                                 .peek_last(peek_last[3]));

    always@(posedge clk_rd or negedge rst_n_r) 
    begin
        if(rst_n_r==1'b0)
            rd_d1<=4'b0;
        else
            rd_d1<=rd;
    end

    always@(posedge clk_rd or negedge rst_n_r)   // choose one mem output 
    begin
        if(rst_n_r==1'b0)
        begin
            mux_out<=80'b0;
        end
        else
        begin
            case(rd_d1)
            4'b0001: 
                        begin
                            mux_out<=pkt[0];
                        end
            4'b0010:
                        begin
                            mux_out<=pkt[1];
                        end
            4'b0100:
                        begin
                            mux_out<=pkt[2];
                        end
            4'b1000:
                        begin
                            mux_out<=pkt[3];
                        end
            default: 
                        begin
                            mux_out<=80'b0;
                        end
            endcase
        end 
   end        
    
endmodule    
    






//=====================================================================
// Project : ethernet switch
// File Name : fifo_ctrl.v
// Description : fifo controller, combination of 4 single fifo controller and a round robin output control
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module fifo_ctrl#(
    parameter pt_wd=10
)(
    input clk_fe_wr,
    input clk_ge_wr,
    input clk_rd,
    input [pt_wd:0] left_0,
    input [pt_wd:0] left_1,
    input [9:0] left_2,
    input [9:0] left_3,
    input [20:0] f_in_0,
    input [20:0] f_in_1,
    input [20:0] f_in_2,
    input [20:0] f_in_3,
    input [3:0] rd_end,
    input [3:0] crc_err,
    input rst_n_ge_w,
    input rst_n_fe_w,
    input rst_n_r,
    input [3:0] peek_last,
    output [3:0] disc,
    output [3:0] wr,
    output [3:0] rd,
    output [1:0] last_ge,
    output [1:0] last_fe,
    output [1:0] loss_ge,
    output [1:0] loss_fe,
    output [1:0] error_ge,
    output [1:0] error_fe,
    output [1:0] valid_ge,
    output [1:0] valid_fe
);

    //wire [3:0] rd_end;
    wire [3:0] rd_req;
   // wire [3:0] last_sg;
   // wire [3:0] loss_sg;
   // wire [3:0] error_sg;
   // wire [3:0] valid_sg;

   // assign last=last_sg;
   // assign loss=loss_sg;
   // assign error=error_sg;
   // assign valid=valid_sg;

               // 4 single controllers
    fifo_ctrl_sg #(.pt_wd(pt_wd)) fifo_ctrl_sg_inst_0(.clk_wr(clk_ge_wr), 
                                                               .clk_rd(clk_rd), 
                                                               .left(left_0), 
                                                               .fin_n(f_in_0), 
                                                               .crc_err(crc_err[0]), 
                                                               .rst_n_w(rst_n_ge_w),
                                                               .rst_n_r(rst_n_r), 
                                                               .rd_end(rd_end[0]), 
                                                               .wr(wr[0]), 
                                                               .rd_req(rd_req[0]), 
                                                               .disc(disc[0]), 
                                                               .last_out(last_ge[0]), 
                                                               .loss_out(loss_ge[0]),
                                                               .error_out(error_ge[0]),
                                                               .valid_out(valid_ge[0]));
                            
    fifo_ctrl_sg #(.pt_wd(pt_wd)) fifo_ctrl_sg_inst_1(.clk_wr(clk_ge_wr), 
                                                               .clk_rd(clk_rd), 
                                                               .left(left_1), 
                                                               .fin_n(f_in_1), 
                                                               .crc_err(crc_err[1]), 
                                                               .rst_n_w(rst_n_ge_w),
                                                               .rst_n_r(rst_n_r), 
                                                               .rd_end(rd_end[1]), 
                                                               .wr(wr[1]), 
                                                               .rd_req(rd_req[1]), 
                                                               .disc(disc[1]), 
                                                               .last_out(last_ge[1]), 
                                                               .loss_out(loss_ge[1]),
                                                               .error_out(error_ge[1]),
                                                               .valid_out(valid_ge[1]));        

    fifo_ctrl_sg fifo_ctrl_sg_inst_2(.clk_wr(clk_fe_wr), 
                                                  .clk_rd(clk_rd), 
                                                  .left(left_2), 
                                                  .fin_n(f_in_2), 
                                                  .crc_err(crc_err[2]), 
                                                  .rst_n_w(rst_n_fe_w),
                                                  .rst_n_r(rst_n_r), 
                                                  .rd_end(rd_end[2]), 
                                                  .wr(wr[2]), 
                                                  .rd_req(rd_req[2]), 
                                                  .disc(disc[2]), 
                                                  .last_out(last_fe[0]), 
                                                  .loss_out(loss_fe[0]),
                                                  .error_out(error_fe[0]), 
                                                  .valid_out(valid_fe[0]));
                            
    fifo_ctrl_sg fifo_ctrl_sg_inst_3(.clk_wr(clk_fe_wr), 
                                                .clk_rd(clk_rd), 
                                                .left(left_3), 
                                                .fin_n(f_in_3), 
                                                .crc_err(crc_err[3]), 
                                                .rst_n_w(rst_n_fe_w),
                                                .rst_n_r(rst_n_r),  
                                                .rd_end(rd_end[3]), 
                                                .wr(wr[3]),
                                                .rd_req(rd_req[3]), 
                                                .disc(disc[3]), 
                                                .last_out(last_fe[1]), 
                                                .loss_out(loss_fe[1]),
                                                .error_out(error_fe[1]), 
                                                .valid_out(valid_fe[1]));                                
               //round robin 
    round_robin rr_inst(.req(rd_req), 
                                 .clk_rd(clk_rd), 
                                  .rst_n(rst_n_r), 
                                  .rd(rd),
                                  .peek_last(peek_last));
    
endmodule






//=====================================================================
// Project : ethernet switch
// File Name : fifo_ctrl_sg.v
// Description : single fifo controller
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
//only need discard mem when crc error occurs
// insufficient storage leads to discarding incoming pkts
// loss_out both loss and disc
module fifo_ctrl_sg#(
    parameter pt_wd=9
)(
    input clk_wr,
    input clk_rd,
    input [pt_wd:0] left,
    input [20:0] fin_n,       // pre dff input
    input crc_err,         // pre dff
    input rst_n_w,
    input rst_n_r,
    input rd_end,
    output reg wr,
    output reg rd_req,
    output reg disc,
    output reg last_out,
    output reg loss_out,
    output reg error_out,
    output  valid_out
);
  
    reg se_err;
    reg sof_got; 
    reg disc_flag; 
    reg disc_flag_on;
    reg disc_in;         //discard incoming
    
    reg disc_in_d1;
    reg free_d1;
    reg eof_d1;
    reg valid_d1;
    
    reg [9:0] wr_cnt;
    reg [9:0] rd_cnt;
    
    reg current_state;
    reg next_state;
    
    reg last;            // sof eof state machine last
    reg loss;
    reg [pt_wd:0] left_d1;
    
    wire error;
    wire sof;
    wire eof;
    wire valid;
    wire [pt_wd+3:0] left_bytes;
    wire free;     //free room
    
    //wire eof_synch_rd;
    
    parameter transmission=1'b1;
    parameter start=1'b0;
    
   // synch synch_inst_eof_to_rd(
     //                          .clk(clk_rd),
     //                          .rst_n(rst_n_r),
    //                           .data_a(eof),
      //                         .data_s(eof_synch_rd)
     //                          );
    
    assign sof=fin_n[18];
    assign eof=fin_n[17]|(fin_n[16]&fin_n[19]);
    assign valid=fin_n[20];
    assign left_bytes=left_d1*{{(pt_wd){1'b0}},{4'd8}};
    assign free=(fin_n[pt_wd+3:0]<=left_bytes);
    assign error=se_err|crc_err;
    assign valid_out=valid_d1;
    
    always@ (posedge clk_wr or negedge rst_n_w) 
    begin
        if(rst_n_w==1'b0)
        begin
            loss_out<=1'b0;
            error_out<=1'b0;
            last_out<=1'b0;
            //valid_out<=1'b0;
        end
        else
        begin
            loss_out<=(loss|disc_in|disc_flag)&last;   //only high if loss and last
            error_out<=error;
            last_out<=last;
            //valid_out<=valid;
        end
    end
    
    always@(posedge clk_wr or negedge rst_n_w)    //storage counter update
    begin
        if(rst_n_w==1'b0)
              wr_cnt<=10'b0;
        else if(!valid)
            wr_cnt<=wr_cnt;
        else if(eof&&wr)
              wr_cnt<=wr_cnt+1'b1;
    end

      always@(posedge clk_rd or negedge rst_n_r)    //storage counter update
      begin
          if(rst_n_r==1'b0)
                rd_cnt<=10'b0;
         else
          begin
             if(rd_end)
                 rd_cnt<=rd_cnt+1'b1;
             else
                 rd_cnt<=rd_cnt;
          end
    end
    
    always@(wr_cnt or rd_cnt or rd_end or rst_n_r)        // read request logic
    begin
        rd_req=1'b0;
        if((wr_cnt!=rd_cnt)&&rst_n_r==1'b1&&!rd_end)
            rd_req=1'b1;
    end
    
    always@(valid or disc_flag or sof_got or sof or crc_err or free or rst_n_w)       //write logic
    begin
        wr=1'b0;
        disc=1'b0;
        disc_in=1'b0;
        if(rst_n_w==1'b0)
        begin
            wr=1'b0;
            disc=1'b0;
        end
        else if(valid&&(!disc_flag)&&(sof_got||sof))
        begin
            if(crc_err)       // crc error, dicard  mem
                  disc=1'b1;     
            else if(!sof)    // not first
                  wr=1'b1;
            else if(free)
                  wr=1'b1;
            else       
                  disc_in=1'b1;
       end   
       else wr=1'b0;
     
    end
    
    always@(posedge clk_wr or negedge rst_n_w)      //state update
    begin
      if(rst_n_w==1'b0)
        current_state<=start;
      else 
        current_state<=next_state;
    end
    
    always@(posedge clk_wr or negedge rst_n_w)   // flag update
    begin
        if(rst_n_w==1'b0)
        begin
              sof_got<=1'b0; 
        end
        else if(valid)
          begin
            if(sof==1'b1)
                  sof_got<=1'b1;
            else
              if(eof==1'b1)
              begin
                  sof_got<=1'b0; 
              end 
          end
    end
    
    always@(*)
    begin
        if((!free_d1)&&disc_in_d1)
            disc_flag=1'b1;
        else if(valid_d1&&eof_d1)
            disc_flag=1'b0;
        else if(disc_flag_on)
            disc_flag=1'b1;
        else
            disc_flag=1'b0;
        //else disc_flag<=disc_flag;
        //     
    end
    
    always@(posedge clk_wr or negedge rst_n_w)
    begin
        if(rst_n_w==1'b0)
            disc_flag_on=1'b0;
        else if((!free_d1)&&disc_in_d1)
            disc_flag_on=1'b1;
        else if(valid_d1&&eof_d1)
            disc_flag_on=1'b0;
    end
    
    always@(posedge clk_wr or negedge rst_n_w)
    begin
        if(rst_n_w==1'b0)
        begin
            free_d1<=1'b0;
            disc_in_d1<=1'b0;
            eof_d1<=1'b0;
            valid_d1<=1'b0;
            left_d1<={(pt_wd+1){1'b0}};
        end
        else
        begin
            free_d1<=free;
            disc_in_d1<=disc_in;
            eof_d1<=eof;
            valid_d1<=valid;
            left_d1<=left;
        end
    end
    
    always@(valid or current_state or sof or eof or rst_n_w)     // state transmission and mealy output
    begin
        if(rst_n_w==1'b0)
          begin
              se_err=1'b0;
              loss=1'b0;
              last=1'b0;
              next_state=start;        
          end
        else if(valid==1'b1)
          begin
            if(current_state==start)
              begin
                  if(sof==1'b1)
                  begin
                      se_err=1'b0;
                      loss=1'b0;
                      last=1'b0;
                      next_state=transmission;        
                 end
              else if(eof==1'b1)
              begin
                  se_err=1'b1;
                  loss=1'b1;
                  last=1'b1;
                next_state=start;
              end
              else
              begin
                  se_err=1'b1;
                  loss=1'b1;
                  last=1'b0;
                next_state=start; 
             end
          end
        else if(current_state==transmission)      
          begin
              if(sof==1'b1)
              begin
                  se_err=1'b1;
                  loss=1'b1;
                  last=1'b1;
                next_state=transmission;        
              end
              else if(eof==1'b1)
              begin
                  se_err=1'b0;
                  loss=1'b0;
                  last=1'b1;
                next_state=start;
              end
              else
              begin
                  se_err=1'b0;
                  loss=1'b0;
                  last=1'b0;
                next_state=transmission; 
              end
           end 
		else 
        begin
            se_err=1'b0;
            loss=1'b0;
            last=1'b0;
            next_state=current_state;
        end		
      end
      else
      begin
            se_err=1'b0;
            loss=1'b0;
            last=1'b0;
            next_state=current_state;
      end
   end
endmodule









//=====================================================================
// Project : ethernet switch
// File Name : fifo_groups.v
// Description : fifo groups, 4 fifos
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module fifo_groups(
    input clk_ge_wr,
    input clk_fe_wr,
    input clk_ge_rd,
    input clk_fe_rd,
    input rst_n_ge_w,
    input rst_n_fe_w,
    input rst_n_ge_r,
    input rst_n_fe_r,
    input [3:0] crc_err_0,
    input [3:0] crc_err_1,
    input [3:0] crc_err_2,
    input [3:0] crc_err_3,
    
    input [79:0] pkt0_0_0,
    input [79:0] pkt0_1_0,
    input [79:0] pkt0_2_0,
    input [79:0] pkt0_3_0,
    input [79:0] pkt1_0_0,
    input [79:0] pkt1_1_0,
    input [79:0] pkt1_2_0,
    input [79:0] pkt1_3_0,

    input [79:0] pkt0_0_1,
    input [79:0] pkt0_1_1,
    input [79:0] pkt0_2_1,
    input [79:0] pkt0_3_1,
    input [79:0] pkt1_0_1,
    input [79:0] pkt1_1_1,
    input [79:0] pkt1_2_1,
    input [79:0] pkt1_3_1,

    input [79:0] pkt0_0_2,
    input [79:0] pkt0_1_2,
    input [79:0] pkt0_2_2,
    input [79:0] pkt0_3_2,
    input [79:0] pkt1_0_2,
    input [79:0] pkt1_1_2,
    input [79:0] pkt1_2_2,
    input [79:0] pkt1_3_2,

    input [79:0] pkt0_0_3,
    input [79:0] pkt0_1_3,
    input [79:0] pkt0_2_3,
    input [79:0] pkt0_3_3,
    input [79:0] pkt1_0_3,
    input [79:0] pkt1_1_3,
    input [79:0] pkt1_2_3,
    input [79:0] pkt1_3_3,
    
    output  [1:0] loss_0_ge,
    output  [1:0] loss_1_ge,
    output  [1:0] loss_2_ge,
    output  [1:0] loss_3_ge,
    output  [1:0] error_0_ge,
    output  [1:0] error_1_ge,
    output  [1:0] error_2_ge,
    output  [1:0] error_3_ge,
    output  [1:0] last_0_ge,
    output  [1:0] last_1_ge,
    output  [1:0] last_2_ge,
    output  [1:0] last_3_ge,
    output  [1:0] valid_0_ge,
    output  [1:0] valid_1_ge,
    output  [1:0] valid_2_ge,
    output  [1:0] valid_3_ge,
    
    output  [1:0] loss_0_fe,
    output  [1:0] loss_1_fe,
    output  [1:0] loss_2_fe,
    output  [1:0] loss_3_fe,
    output  [1:0] error_0_fe,
    output  [1:0] error_1_fe,
    output  [1:0] error_2_fe,
    output  [1:0] error_3_fe,
    output  [1:0] last_0_fe,
    output  [1:0] last_1_fe,
    output  [1:0] last_2_fe,
    output  [1:0] last_3_fe,
    output  [1:0] valid_0_fe,
    output  [1:0] valid_1_fe,
    output  [1:0] valid_2_fe,
    output  [1:0] valid_3_fe,
    
    output switched_data_valid_0,
    output [63:0] switched_data_0,
    output [2:0] switched_data_bytes_0,
    output switched_sof_0,
    output switched_eof_0,
    output [9:0] switched_block_tag_0,
    
    output switched_data_valid_1,
    output [63:0] switched_data_1,
    output [2:0] switched_data_bytes_1,
    output switched_sof_1,
    output switched_eof_1,
    output [9:0] switched_block_tag_1,
    
    output switched_data_valid_2,
    output [63:0] switched_data_2,
    output [2:0] switched_data_bytes_2,
    output switched_sof_2,
    output switched_eof_2,
    output [9:0] switched_block_tag_2,
    
    output switched_data_valid_3,
    output [63:0] switched_data_3,
    output [2:0] switched_data_bytes_3,
    output switched_sof_3,
    output switched_eof_3,
    output [9:0] switched_block_tag_3

);
    fifo fifo_inst_0(.clk_fe_wr(clk_fe_wr),
                     .clk_ge_wr(clk_ge_wr),
                     .clk_rd(clk_ge_rd),
                     .rst_n_ge_w(rst_n_ge_w),
                     .rst_n_fe_w(rst_n_fe_w),
                     .rst_n_r(rst_n_ge_r),
                     .crc_err(crc_err_0),
                     .pkt0_0(pkt0_0_0),
                     .pkt1_0(pkt1_0_0),
                     .pkt0_1(pkt0_1_0),
                     .pkt1_1(pkt1_1_0),
                     .pkt0_2(pkt0_2_0),
                     .pkt1_2(pkt1_2_0),
                     .pkt0_3(pkt0_3_0),
                     .pkt1_3(pkt1_3_0),
                     .last_ge(last_0_ge),
                     .loss_ge(loss_0_ge),
                     .error_ge(error_0_ge),
                     .valid_ge(valid_0_ge),
                     .last_fe(last_0_fe),
                     .loss_fe(loss_0_fe),
                     .error_fe(error_0_fe),
                     .valid_fe(valid_0_fe),
                     .switched_data_valid(switched_data_valid_0),
                     .switched_data(switched_data_0),
                     .switched_data_bytes(switched_data_bytes_0),
                     .switched_sof(switched_sof_0),
                     .switched_eof(switched_eof_0),
                     .switched_block_tag(switched_block_tag_0)
                     );
                     
    fifo fifo_inst_1(.clk_fe_wr(clk_fe_wr),
                     .clk_ge_wr(clk_ge_wr),
                     .clk_rd(clk_ge_rd),
                     .rst_n_ge_w(rst_n_ge_w),
                     .rst_n_fe_w(rst_n_fe_w),
                     .rst_n_r(rst_n_ge_r),
                     .crc_err(crc_err_1),
                     .pkt0_0(pkt0_0_1),
                     .pkt1_0(pkt1_0_1),
                     .pkt0_1(pkt0_1_1),
                     .pkt1_1(pkt1_1_1),
                     .pkt0_2(pkt0_2_1),
                     .pkt1_2(pkt1_2_1),
                     .pkt0_3(pkt0_3_1),
                     .pkt1_3(pkt1_3_1),
                     .last_ge(last_1_ge),
                     .loss_ge(loss_1_ge),
                     .error_ge(error_1_ge),
                     .valid_ge(valid_1_ge),
                     .last_fe(last_1_fe),
                     .loss_fe(loss_1_fe),
                     .error_fe(error_1_fe),
                     .valid_fe(valid_1_fe),
                     .switched_data_valid(switched_data_valid_1),
                     .switched_data(switched_data_1),
                     .switched_data_bytes(switched_data_bytes_1),
                     .switched_sof(switched_sof_1),
                     .switched_eof(switched_eof_1),
                     .switched_block_tag(switched_block_tag_1)
                     );
                     
    fifo         fifo_inst_2(.clk_fe_wr(clk_fe_wr),
                     .clk_ge_wr(clk_ge_wr),
                     .clk_rd(clk_fe_rd),
                     .rst_n_ge_w(rst_n_ge_w),
                     .rst_n_fe_w(rst_n_fe_w),
                     .rst_n_r(rst_n_fe_r),
                     .crc_err(crc_err_2),
                     .pkt0_0(pkt0_0_2),
                     .pkt1_0(pkt1_0_2),
                     .pkt0_1(pkt0_1_2),
                     .pkt1_1(pkt1_1_2),
                     .pkt0_2(pkt0_2_2),
                     .pkt1_2(pkt1_2_2),
                     .pkt0_3(pkt0_3_2),
                     .pkt1_3(pkt1_3_2),
                     .last_ge(last_2_ge),
                     .loss_ge(loss_2_ge),
                     .error_ge(error_2_ge),
                     .valid_ge(valid_2_ge),
                     .last_fe(last_2_fe),
                     .loss_fe(loss_2_fe),
                     .error_fe(error_2_fe),
                     .valid_fe(valid_2_fe),
                     .switched_data_valid(switched_data_valid_2),
                     .switched_data(switched_data_2),
                     .switched_data_bytes(switched_data_bytes_2),
                     .switched_sof(switched_sof_2),
                     .switched_eof(switched_eof_2),
                     .switched_block_tag(switched_block_tag_2)
                     );
                     
    fifo //#(.pt_wd(12),.sp_dp(4096)) 
         fifo_inst_3(.clk_fe_wr(clk_fe_wr),
                     .clk_ge_wr(clk_ge_wr),
                     .clk_rd(clk_fe_rd),
                     .rst_n_ge_w(rst_n_ge_w),
                     .rst_n_fe_w(rst_n_fe_w),
                     .rst_n_r(rst_n_fe_r),
                     .crc_err(crc_err_3),
                     .pkt0_0(pkt0_0_3),
                     .pkt1_0(pkt1_0_3),
                     .pkt0_1(pkt0_1_3),
                     .pkt1_1(pkt1_1_3),
                     .pkt0_2(pkt0_2_3),
                     .pkt1_2(pkt1_2_3),
                     .pkt0_3(pkt0_3_3),
                     .pkt1_3(pkt1_3_3),
                     .last_ge(last_3_ge),
                     .loss_ge(loss_3_ge),
                     .error_ge(error_3_ge),
                     .valid_ge(valid_3_ge),
                     .last_fe(last_3_fe),
                     .loss_fe(loss_3_fe),
                     .error_fe(error_3_fe),
                     .valid_fe(valid_3_fe),
                     .switched_data_valid(switched_data_valid_3),
                     .switched_data(switched_data_3),
                     .switched_data_bytes(switched_data_bytes_3),
                     .switched_sof(switched_sof_3),
                     .switched_eof(switched_eof_3),
                     .switched_block_tag(switched_block_tag_3)
                     );
                     
endmodule                     








//=====================================================================
// Project : ethernet switch
// File Name : logic32_table.v
// Description : 32 logic flow switching component 
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module logic32_table(
    input rd,
    input wr,
    input clk_sw,
    input clk_cfig,
    input [47:0] DA,
    input sof,
    input valid,
    input rst_n,
    input rst_upi_n,
    input [5:0] addr,
    input [5:0] addr_upi,
    input [31:0] ifdata,
    output reg [31:0] data_out, 
    output reg [1:0] port_num
    );
    
    reg [1:0] port_out;           //output result
    reg [1:0] port_out_hold;
    reg [49:0] memory [31:0];    // table memory
    //reg [31:0] match;             // DA match flag
    //reg [49:0] da_in;
    wire [4:0] eff_addr;
    wire [4:0] eff_addr_upi;
 
    //integer i;
    //integer j;

   //assign port_num=port_out;
   assign eff_addr=addr[4:0];
   assign eff_addr_upi=addr_upi[4:0];

  always@(*)     // sw read
  begin
      if(sof==1'b1&&valid==1'b1)
      begin      
          if(memory[0][49:2]==DA)
              port_out=memory[0][1:0];
          else if(memory[1][49:2]==DA)
              port_out=memory[1][1:0];
          else if(memory[2][49:2]==DA)
              port_out=memory[2][1:0];
          else if(memory[3][49:2]==DA)
              port_out=memory[3][1:0];
          else if(memory[4][49:2]==DA)
              port_out=memory[4][1:0];
          else if(memory[5][49:2]==DA)
              port_out=memory[5][1:0];
          else if(memory[6][49:2]==DA)
              port_out=memory[6][1:0];
          else if(memory[7][49:2]==DA)
              port_out=memory[7][1:0];
          else if(memory[8][49:2]==DA)
              port_out=memory[8][1:0];
          else if(memory[9][49:2]==DA)
              port_out=memory[9][1:0];
          else if(memory[10][49:2]==DA)
              port_out=memory[10][1:0];
          else if(memory[11][49:2]==DA)
              port_out=memory[11][1:0];
          else if(memory[12][49:2]==DA)
              port_out=memory[12][1:0];
          else if(memory[13][49:2]==DA)
              port_out=memory[13][1:0];
          else if(memory[14][49:2]==DA)
              port_out=memory[14][1:0];
          else if(memory[15][49:2]==DA)
              port_out=memory[15][1:0];
          else if(memory[16][49:2]==DA)
              port_out=memory[16][1:0];
          else if(memory[17][49:2]==DA)
              port_out=memory[17][1:0];
          else if(memory[18][49:2]==DA)
              port_out=memory[18][1:0];
          else if(memory[19][49:2]==DA)
              port_out=memory[19][1:0];
          else if(memory[20][49:2]==DA)
              port_out=memory[20][1:0];
          else if(memory[21][49:2]==DA)
              port_out=memory[21][1:0];
          else if(memory[22][49:2]==DA)
              port_out=memory[22][1:0];
          else if(memory[23][49:2]==DA)
              port_out=memory[23][1:0];
          else if(memory[24][49:2]==DA)
              port_out=memory[24][1:0];
          else if(memory[25][49:2]==DA)
              port_out=memory[25][1:0];
          else if(memory[26][49:2]==DA)
              port_out=memory[26][1:0];
          else if(memory[27][49:2]==DA)
              port_out=memory[27][1:0];
          else if(memory[28][49:2]==DA)
              port_out=memory[28][1:0];
          else if(memory[29][49:2]==DA)
              port_out=memory[29][1:0];
          else if(memory[30][49:2]==DA)
              port_out=memory[30][1:0];
          else if(memory[31][49:2]==DA)
              port_out=memory[31][1:0];
          else 
              port_out=2'b0;              
      end
      else
          port_out=2'b0;
      
   end

   always@(posedge clk_sw or negedge rst_n)      // hold first result
   begin
       if(rst_n==1'b0)
           port_out_hold<=2'b0;
       else if(sof==1'b1&&valid==1'b1)
           port_out_hold<=port_out;
   end
   
   always@(sof or valid or port_out or port_out_hold)    //output 
   begin
       if(sof==1'b1&&valid==1'b1)
           port_num=port_out;
        else
           port_num=port_out_hold;
   end
   
   always@(posedge clk_sw or negedge rst_n)     // config  write  sw clock
   begin
       if(rst_n==1'b0)
       begin
           memory[0]<=50'b0;
           memory[1]<=50'b0;
           memory[2]<=50'b0;
           memory[3]<=50'b0;
           memory[4]<=50'b0;
           memory[5]<=50'b0;
           memory[6]<=50'b0;
           memory[7]<=50'b0;
           memory[8]<=50'b0;
           memory[9]<=50'b0;
           memory[10]<=50'b0;
           memory[11]<=50'b0;
           memory[12]<=50'b0;
           memory[13]<=50'b0;
           memory[14]<=50'b0;
           memory[15]<=50'b0;
           memory[16]<=50'b0;
           memory[17]<=50'b0;
           memory[18]<=50'b0;
           memory[19]<=50'b0;
           memory[20]<=50'b0;
           memory[21]<=50'b0;
           memory[22]<=50'b0;
           memory[23]<=50'b0;
           memory[24]<=50'b0;
           memory[25]<=50'b0;
           memory[26]<=50'b0;
           memory[27]<=50'b0;
           memory[28]<=50'b0;
           memory[29]<=50'b0;
           memory[30]<=50'b0;
           memory[31]<=50'b0;
           
       end
       else if(wr==1'b1)   // if data valid, wr prohibited
       begin
          if(addr<6'd32)
              memory[eff_addr][49:18]<=ifdata;
          else
              memory[eff_addr][17:0]<=ifdata[31:14];         
       end
   end
    

   always@(posedge clk_cfig or negedge rst_upi_n)                //config read
   begin
       if(rst_upi_n==1'b0)
           data_out<=32'b0;
       else if(rd==1'b1)
       begin
           if(addr_upi<6'd32)
               data_out<=memory[eff_addr_upi][49:18];
           else
               data_out[31:14]<=memory[eff_addr_upi][17:0];
       end 
   end

endmodule




//=====================================================================
// Project : ethernet switch
// File Name : mem.v
// Description : memory, storage component in fifo
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module mem #(
    parameter depth=10'd512,
    parameter pt_wd=9)
(
    input [79:0] pkt0,
    input [79:0] pkt1,
    input rd,
    input wr,
    input clk_r,
    input clk_w,
    input rst_n_w,
    input rst_n_r,
    input disc,
    output reg [79:0] pkt,
    output reg peek_last,
    output [pt_wd:0] left
);
    reg [79:0] memory [depth-1:0];
    reg [pt_wd-1:0] r_pt;
    reg [pt_wd-1:0] w_pt;
    reg [pt_wd-1:0] pre_pt;
    reg [pt_wd-1:0] r_pt_bin;
    reg loop_w;
    reg loop_r;
    wire loop_r_syn;
    wire [pt_wd-1:0] r_pt_gray;
    wire [pt_wd-1:0] r_pt_gray_syn;
    
    wire pre_eof;

    assign left=(loop_r_syn==loop_w)?(depth-(w_pt-r_pt_bin)):(r_pt_bin-w_pt);

    assign pre_eof=memory[r_pt][10];
    assign r_pt_gray=(r_pt>>1'b1)^r_pt;
    
    synch synch_inst_loop_r(
                                 .clk(clk_w),
                                 .rst_n(rst_n_w),
                                 .data_a(loop_r),
                                 .data_s(loop_r_syn));    
    
    generate
    genvar i;
    for(i=0;i<pt_wd;i=i+1)
    begin: synch_loop
        synch synch_inst(
                                     .clk(clk_w),
                                     .rst_n(rst_n_w),
                                     .data_a(r_pt_gray[i]),
                                     .data_s(r_pt_gray_syn[i]));
    end
    endgenerate
    
    
    integer k;
    always@(r_pt_gray_syn)
    begin
        for(k=0;k<pt_wd;k=k+1)
        r_pt_bin[k]=^(r_pt_gray_syn>>k);
    end
    
    always@(rst_n_w or r_pt or w_pt or loop_r or loop_w  or pre_eof)         //early last block check
    begin
        if(rst_n_w==1'b0)
            peek_last=1'b0;
        else if(((r_pt<w_pt)||loop_r!=loop_w)&&pre_eof)
            peek_last=1'b1;
        else
            peek_last=1'b0;
    end


    always@(posedge clk_w or negedge rst_n_w)    //write logic
    begin
      if(rst_n_w==1'b0)
      begin
         // r_pt<={(pt_wd){1'b0}};
          w_pt<={(pt_wd){1'b0}};
          pre_pt<={(pt_wd){1'b0}};
          loop_w<=1'b0;
      end
      else if(wr==1'b1&&disc==1'b0)
        begin
            if(pkt0[11]==1'b1)    // check sof, record last addr
                pre_pt<=w_pt;
          
            if(pkt1[79]==1'b0)   // write pkt0
          begin      
                memory[w_pt]<=pkt0;
                w_pt<=w_pt+1'b1;
              if({{1'b0},w_pt}==(depth-1'b1))
                  loop_w<=~loop_w;
            end
            else                  // write pkt0 and pkt1
            begin
                memory[w_pt]<=pkt0;
                memory[w_pt+1]<=pkt1;
                w_pt<=w_pt+2'd2;
              if({{1'b0},w_pt}>=depth-2'd2)
                  loop_w<=~loop_w;
          end
        end
        else if(wr==1'b1&&disc==1'b1)  //write and discard
        begin
            if(pkt1[79]==1'b0)     // write pkt0
          begin      
                memory[pre_pt]<=pkt0;
                w_pt<=pre_pt+1'b1;
              if({{1'b0},w_pt}==depth-1'b1)
                 loop_w<=~loop_w;
            end
            else                    // write pkt0 and pkt1
            begin
                memory[pre_pt]<=pkt0;
                memory[pre_pt+1]<=pkt1;
                w_pt<=pre_pt+2'd2;
              if({{1'b0},w_pt}>=depth-2'd2)
                  loop_w<=~loop_w;
          end
        end
        else if(wr==1'b0&&disc==1'b1)    //discard
        begin
            w_pt<=pre_pt;
        end
    end
    
    always@(posedge clk_r or negedge rst_n_r)     //mem output
    begin
        if(rst_n_r==1'b0)
        begin
            r_pt<={(pt_wd){1'b0}};
            //w_pt<={(pt_wd){1'b0}};
            //pre_pt<={(pt_wd){1'b0}};
            pkt<=80'b0;
            loop_r<=1'b0;
        end
        else if(rd==1'b1)
          begin
              pkt<=memory[r_pt];
              r_pt<=r_pt+1'b1;
            if({{1'b0},r_pt}==depth-2'd1)
                loop_r<=~loop_r;
          end
          else
              pkt<=80'b0;
    end
endmodule









//=====================================================================
// Project : ethernet switch
// File Name : pkt_spl.v
// Description : combination of 4 splitting logic and dff output
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module pkt_spl(
    input clk_fe,
    input clk_ge,
    input rst_n_ge_w,
    input rst_n_fe_w,

    input data_valid_0,
    input [127:0] data_0,
    input [3:0] data_bytes_0,
    input sof_0,
    input eof_0,
    input [9:0] block_tag_0,
    output  [79:0] ps_pkt0_0,
    output  [79:0] ps_pkt1_0,

    input data_valid_1,
    input [127:0] data_1,
    input [3:0] data_bytes_1,
    input sof_1,
    input eof_1,
    input [9:0] block_tag_1,
    output  [79:0] ps_pkt0_1,
    output  [79:0] ps_pkt1_1,

    input data_valid_2,
    input [127:0] data_2,
    input [3:0] data_bytes_2,
    input sof_2,
    input eof_2,
    input [9:0] block_tag_2,
    output  [79:0] ps_pkt0_2,
    output  [79:0] ps_pkt1_2,

    input data_valid_3,
    input [127:0] data_3,
    input [3:0] data_bytes_3,
    input sof_3,
    input eof_3,
    input [9:0] block_tag_3,
    output  [79:0] ps_pkt0_3,
    output  [79:0] ps_pkt1_3
    );


  spl_logic spl_logic_inst0(.data_valid(data_valid_0),
                                      .data(data_0), 
                                      .clk(clk_ge),
                                      .rst_n(rst_n_ge_w),
                                      .data_bytes(data_bytes_0),
                                      .sof(sof_0), 
                                      .eof(eof_0), 
                                      .block_tag(block_tag_0), 
                                      .pkt0_out(ps_pkt0_0), 
                                      .pkt1_out(ps_pkt1_0));

  spl_logic spl_logic_inst1(.data_valid(data_valid_1), 
                                      .data(data_1),
                                      .clk(clk_ge),
                                      .rst_n(rst_n_ge_w),
                                      .data_bytes(data_bytes_1),
                                      .sof(sof_1), 
                                      .eof(eof_1), 
                                      .block_tag(block_tag_1), 
                                      .pkt0_out(ps_pkt0_1), 
                                      .pkt1_out(ps_pkt1_1));

  spl_logic spl_logic_inst2(.data_valid(data_valid_2), 
                                     .data(data_2),
                                     .clk(clk_fe),
                                     .rst_n(rst_n_fe_w),
                                     .data_bytes(data_bytes_2),
                                     .sof(sof_2), 
                                     .eof(eof_2), 
                                     .block_tag(block_tag_2), 
                                     .pkt0_out(ps_pkt0_2), 
                                     .pkt1_out(ps_pkt1_2));

  spl_logic spl_logic_inst3(.data_valid(data_valid_3), 
                                     .data(data_3),
                                     .clk(clk_fe),
                                     .rst_n(rst_n_fe_w),
                                     .data_bytes(data_bytes_3),
                                     .sof(sof_3), 
                                     .eof(eof_3), 
                                     .block_tag(block_tag_3), 
                                     .pkt0_out(ps_pkt0_3), 
                                     .pkt1_out(ps_pkt1_3));



 
endmodule





//=====================================================================
// Project : ethernet switch
// File Name : round_robin.v
// Description : round robin algorithm for fifo output
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module round_robin(
    input [3:0] req,
    input [3:0] peek_last,
    input clk_rd,
    input rst_n,
    output reg [3:0] rd
);
    reg [1:0] que[5:0];
    reg [1:0] new_que[5:0];
    reg [2:0] index;
    reg [5:0] find_0;
    reg [5:0] find_1;
    reg [5:0] find_2;
    reg [5:0] find_3;
    reg [5:0] level_find;
    reg [3:0] req_d1;
   // reg [3:0] last;
    reg reading;

    always@(posedge clk_rd or negedge rst_n)    //delayed req
    begin
        if(rst_n==1'b0)
        begin
            req_d1<=4'b0;
         //   last<=4'b0;
        end
        else
        begin
            if(reading==1'b0||peek_last!=4'b0)
            req_d1<=req;
            
           // last<=peek_last;
        end
    end
 
  always@(posedge clk_rd or negedge rst_n)   // update que
  begin
      if(rst_n==1'b0)
      begin
          que[0]<=2'd0;
          que[1]<=2'd1;
          que[2]<=2'd2;
          que[3]<=2'd3;
          que[4]<=2'd0;
          que[5]<=2'd1; 
          reading<=1'b0;
        end
        else if(peek_last!=4'b0)
        begin
            que[0]<=new_que[0];
            que[1]<=new_que[1];
            que[2]<=new_que[2];
            que[3]<=new_que[3];
            que[4]<=new_que[4];
            que[5]<=new_que[5];
            reading<=1'b1;
        end
  end
    
  always@(que[0] or que[1] or que[2] or que[3] or que[4] or que[5] or req_d1)                             //request hit logic find
  begin
          find_0[0]=(que[0]==2'd0)&req_d1[0];
          find_0[1]=(que[1]==2'd0)&req_d1[0];
          find_0[2]=(que[2]==2'd0)&req_d1[0];
          find_0[3]=(que[3]==2'd0)&req_d1[0];
          find_0[4]=(que[4]==2'd0)&req_d1[0];
          find_0[5]=(que[5]==2'd0)&req_d1[0];
          
          find_1[0]=(que[0]==2'd1)&req_d1[1];
          find_1[1]=(que[1]==2'd1)&req_d1[1];
          find_1[2]=(que[2]==2'd1)&req_d1[1];
          find_1[3]=(que[3]==2'd1)&req_d1[1];
          find_1[4]=(que[4]==2'd1)&req_d1[1];
          find_1[5]=(que[5]==2'd1)&req_d1[1];
          
          find_2[0]=(que[0]==2'd2)&req_d1[2];
          find_2[1]=(que[1]==2'd2)&req_d1[2];
          find_2[2]=(que[2]==2'd2)&req_d1[2];
          find_2[3]=(que[3]==2'd2)&req_d1[2];
          find_2[4]=(que[4]==2'd2)&req_d1[2];
          find_2[5]=(que[5]==2'd2)&req_d1[2];
          
          find_3[0]=(que[0]==2'd3)&req_d1[3];
          find_3[1]=(que[1]==2'd3)&req_d1[3];
          find_3[2]=(que[2]==2'd3)&req_d1[3];
          find_3[3]=(que[3]==2'd3)&req_d1[3];
          find_3[4]=(que[4]==2'd3)&req_d1[3];
          find_3[5]=(que[5]==2'd3)&req_d1[3];
          
  end
  
  always@(find_0 or find_1 or find_2 or find_3)                           //request hit logic level_find
  begin
          level_find[0]=find_0[0]|find_1[0]|find_2[0]|find_3[0];
          level_find[1]=find_0[1]|find_1[1]|find_2[1]|find_3[1];
          level_find[2]=find_0[2]|find_1[2]|find_2[2]|find_3[2];
          level_find[3]=find_0[3]|find_1[3]|find_2[3]|find_3[3];
          level_find[4]=find_0[4]|find_1[4]|find_2[4]|find_3[4];
          level_find[5]=find_0[5]|find_1[5]|find_2[5]|find_3[5];
  end
  
  always@( level_find
           or que[0] or que[1] or que[2] or que[3] or que[4] or que[5])  //update new_que[5]
  begin
    
      //if(req==4'b0||req_d1==4'b0)
          //rd=4'b0;
      //else  if(reading==1'b0||last!=4'b0)                  //find the req with highest priority
                    
          if(level_find[0])                                // calculate  last element in new queue
          begin
              index=3'd0;
              new_que[5]=que[0];
          end
          else if(level_find[1])
          begin
              index=3'd1;
              new_que[5]=que[1];
          end
          else if(level_find[2])
          begin
              index=3'd2;
              new_que[5]=que[2];
          end
          else if(level_find[3])
          begin
              index=3'd3;
              new_que[5]=que[3];
          end
          else if(level_find[4])
          begin
              index=3'd4;
              new_que[5]=que[4];
          end
          else if(level_find[5])
          begin
              index=3'd5;
              new_que[5]=que[5];
          end
          else
          begin
              index=3'd0;
              new_que[5]=que[0];
          end
  end

  always@(index or que[0] or que[1] or que[2] or que[3] or que[4] or que[5])    
  begin
      if(3'd0<index)                                           //updata new que
          new_que[0]=que[0];
      else
          new_que[0]=que[1];
          
      if(3'd1<index)
          new_que[1]=que[1];
      else
          new_que[1]=que[2];
          
      if(3'd2<index)
          new_que[2]=que[2];
      else
          new_que[2]=que[3];
          
      if(3'd3<index)
          new_que[3]=que[3];
      else
          new_que[3]=que[4];
          
      if(3'd4<index)
          new_que[4]=que[4];
      else
          new_que[4]=que[5];                 
 end

   always@(req or req_d1 or new_que[5])
   begin
      if(req==4'b0||req_d1==4'b0)
          rd=4'b0; 
      else
      begin
          case(new_que[5])                                    //rd signal output 
              2'd0: rd=4'b0001;
              2'd1: rd=4'b0010;
              2'd2: rd=4'b0100;
              2'd3: rd=4'b1000;
              default: rd=4'b0000;
          endcase
      end
   end
  
 endmodule 







//=====================================================================
// Project : ethernet switch
// File Name : spl_logic.v
// Description : splitting logic module, split single port input 
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module spl_logic(
    input data_valid,
    input [127:0] data,
    input [3:0] data_bytes,
    input sof,
    input eof,
    input [9:0] block_tag,
    input clk,
    input rst_n,
    output reg [79:0] pkt0_out,
    output reg [79:0] pkt1_out
    );

    reg [79:0] pkt0;
    reg [79:0] pkt1;
    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            pkt0_out<=80'b0;
            pkt1_out<=80'b0;
        end
        else
        begin
            pkt0_out<=pkt0;
            pkt1_out<=pkt1;
        end
    end


    always@(*)                            //splitting logic
        begin
            pkt0[79]=data_valid;  
            pkt1[79]=data_valid;       //valid can be 0  when data bytes <=7

            pkt0[9:0]=block_tag;
            pkt1[9:0]=block_tag;
            
            pkt0[78:15]=data[127:64];     //pkt0 higher 64 data bits
            pkt1[78:15]=data[63:0];

            if(data_bytes<=4'b0111)          
                begin
                  pkt0[14:12]=data_bytes[2:0];
                  pkt1[14:12]=3'b000;
                  pkt1[79]=1'b0;                 //pkt1 invalid if data_bytes<=7
               end
            else
                begin
                  pkt0[14:12]=3'b111;
                  pkt1[14:12]=data_bytes[2:0];
                end

            if(sof==1'b0)
                begin
                  pkt0[11]=1'b0;
                  pkt1[11]=1'b0;
                end
            else
                begin
                  pkt0[11]=1'b1;
                  pkt1[11]=1'b0;
                end

            if(eof==1'b0)
                begin
                  pkt0[10]=1'b0;
                  pkt1[10]=1'b0;
                 end
             else
                 begin
                   if(data_bytes<=4'b0111)
                     begin
                     pkt0[10]=1'b1;
                     pkt1[10]=1'b0;       //pkt1 invalid if data_bytes<=7,  thus pkt0 is the eof 
                     end
                   else
                       begin
                        pkt0[10]=1'b0;
                        pkt1[10]=1'b1;
                       end
                 end

            end
endmodule





//=====================================================================
// Project : ethernet switch
// File Name : sw_logic.v
// Description : switch logic for one input port
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module sw_logic(
     input wr,
     input rd,
     input [1:0] cp,
     input mode,
     input rst_n,
     input rst_upi_n,
     input clk_sw,
     input clk_cfig,
     input crc_in,
     input [79:0] pkt0,
     input [79:0] pkt1,
     input [5:0] if_addr,
     input [5:0] if_addr_upi,
     input [31:0] if_in,
     output [31:0] if_out,
     output reg [79:0] sw_pkt0_n_0,
     output reg [79:0] sw_pkt0_n_1,
     output reg [79:0] sw_pkt0_n_2,   
     output reg [79:0] sw_pkt0_n_3,
     output reg [79:0] sw_pkt1_n_0,
     output reg [79:0] sw_pkt1_n_1,
     output reg [79:0] sw_pkt1_n_2,   
     output reg [79:0] sw_pkt1_n_3,
     output reg [3:0] crc_out
    );
    
    wire [1:0] port_num;
    reg [1:0] port_num_sel;

    logic32_table logic32_table_inst(.rd(rd),                        // logic table
                                                  .wr(wr), 
                                                  .rst_n(rst_n),
                                                  .rst_upi_n(rst_upi_n),
                                                  .clk_sw(clk_sw),
                                                  .clk_cfig(clk_cfig),
                                                  .DA(pkt0[78:31]), 
                                                  .sof(pkt0[11]),
                                                  .valid(pkt0[79]), 
                                                  .addr(if_addr), 
                                                  .addr_upi(if_addr_upi),
                                                  .ifdata(if_in), 
                                                  .data_out(if_out), 
                                                  .port_num(port_num));

    always@(mode or cp or port_num)                      // choose switch mode
        begin
            case(mode)
                1'b0: port_num_sel=port_num;
                1'b1: port_num_sel=cp; 
                default: port_num_sel=port_num;
            endcase
        end

      always@(pkt0 or pkt1 or port_num_sel or crc_in)        //final switch output
        begin
                  sw_pkt0_n_0=80'b0;
                  sw_pkt0_n_1=80'b0;
                  sw_pkt0_n_2=80'b0;   
                  sw_pkt0_n_3=80'b0;
                  sw_pkt1_n_0=80'b0;
                  sw_pkt1_n_1=80'b0;
                  sw_pkt1_n_2=80'b0;   
                  sw_pkt1_n_3=80'b0;
                  crc_out=4'b0;
            case(port_num_sel)
                2'b00:  begin
                           sw_pkt0_n_0=pkt0;
                           sw_pkt1_n_0=pkt1;
                           crc_out[0]=crc_in;
                           end
                2'b01: begin
                           sw_pkt0_n_1=pkt0;
                           sw_pkt1_n_1=pkt1;
                           crc_out[1]=crc_in;
                           end
                2'b10: begin
                           sw_pkt0_n_2=pkt0;
                           sw_pkt1_n_2=pkt1;
                           crc_out[2]=crc_in;
                           end
                2'b11: begin
                           sw_pkt0_n_3=pkt0;
                           sw_pkt1_n_3=pkt1;
                           crc_out[3]=crc_in;
                           end
            endcase
        end
endmodule




//=====================================================================
// Project : ethernet switch
// File Name : switches.v
// Description : combination of 4 switching logic
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module switches(
    input mode_ge,
    input mode_fe,
    input rst_n_ge_w,
    input rst_n_fe_w,
    input rst_upi_n,
    input clk_ge,
    input clk_fe,
    input clk_cfig,
    input [1:0] wr_ge,
    input [1:0] wr_fe,
    input [1:0] rd_ge,
    input [1:0] rd_fe,
    input [79:0] pkt0_0,
    input [79:0] pkt1_0,
    input [79:0] pkt0_1,
    input [79:0] pkt1_1,
    input [79:0] pkt0_2,
    input [79:0] pkt1_2,
    input [79:0] pkt0_3,
    input [79:0] pkt1_3,
    input [1:0] cp_0,
    input [1:0] cp_1,
    input [1:0] cp_2,
    input [1:0] cp_3,
    input [5:0] if_addr_g,
    input [5:0] if_addr_f,
    input [5:0] if_addr_upi,
    input [31:0] if_in_g,
    input [31:0] if_in_f,
    input [3:0] crc_in,
    
    output reg [31:0] if_out,
    output reg [3:0] valid,

    output [79:0] sw_pkt0_0_0,
    output [79:0] sw_pkt0_0_1,
    output [79:0] sw_pkt0_0_2,
    output [79:0] sw_pkt0_0_3,

    output [79:0] sw_pkt1_0_0,
    output [79:0] sw_pkt1_0_1,
    output [79:0] sw_pkt1_0_2,
    output [79:0] sw_pkt1_0_3,

    output [79:0] sw_pkt0_1_0,
    output [79:0] sw_pkt0_1_1,
    output [79:0] sw_pkt0_1_2,
    output [79:0] sw_pkt0_1_3,

    output [79:0] sw_pkt1_1_0,
    output [79:0] sw_pkt1_1_1,
    output [79:0] sw_pkt1_1_2,
    output [79:0] sw_pkt1_1_3,

    output [79:0] sw_pkt0_2_0,
    output [79:0] sw_pkt0_2_1,
    output [79:0] sw_pkt0_2_2,
    output [79:0] sw_pkt0_2_3,

    output [79:0] sw_pkt1_2_0,
    output [79:0] sw_pkt1_2_1,
    output [79:0] sw_pkt1_2_2,
    output [79:0] sw_pkt1_2_3,

    output [79:0] sw_pkt0_3_0,
    output [79:0] sw_pkt0_3_1,
    output [79:0] sw_pkt0_3_2,
    output [79:0] sw_pkt0_3_3,

    output [79:0] sw_pkt1_3_0,
    output [79:0] sw_pkt1_3_1,
    output [79:0] sw_pkt1_3_2,
    output [79:0] sw_pkt1_3_3,
    
    output reg [3:0] crc_0_d,            //switch logic number, different from fifo_groups numbering
    output reg [3:0] crc_1_d,
    output reg [3:0] crc_2_d,
    output reg [3:0] crc_3_d
   );

    wire [79:0] sw[31:0];          //switching logic to dff
    wire [79:0] swo[31:0];       // dff final output
    
    wire [3:0] crc_0;            //switch logic number, different from fifo_groups numbering
    wire [3:0] crc_1;
    wire [3:0] crc_2;
    wire [3:0] crc_3;
   
    wire [31:0] if_out_sg_0;
    wire [31:0] if_out_sg_1;
    wire [31:0] if_out_sg_2;
    wire [31:0] if_out_sg_3;

    assign sw_pkt0_0_0=swo[0];    // dff output
    assign sw_pkt0_0_1=swo[1];
    assign sw_pkt0_0_2=swo[2];
    assign sw_pkt0_0_3=swo[3];
    assign sw_pkt1_0_0=swo[4];
    assign sw_pkt1_0_1=swo[5];
    assign sw_pkt1_0_2=swo[6];
    assign sw_pkt1_0_3=swo[7];
    assign sw_pkt0_1_0=swo[8];
    assign sw_pkt0_1_1=swo[9];
    assign sw_pkt0_1_2=swo[10];
    assign sw_pkt0_1_3=swo[11];
    assign sw_pkt1_1_0=swo[12];
    assign sw_pkt1_1_1=swo[13];
    assign sw_pkt1_1_2=swo[14];
    assign sw_pkt1_1_3=swo[15];
    assign sw_pkt0_2_0=swo[16];
    assign sw_pkt0_2_1=swo[17];
    assign sw_pkt0_2_2=swo[18];
    assign sw_pkt0_2_3=swo[19];
    assign sw_pkt1_2_0=swo[20];
    assign sw_pkt1_2_1=swo[21];
    assign sw_pkt1_2_2=swo[22];
    assign sw_pkt1_2_3=swo[23];
    assign sw_pkt0_3_0=swo[24];
    assign sw_pkt0_3_1=swo[25];
    assign sw_pkt0_3_2=swo[26];
    assign sw_pkt0_3_3=swo[27];
    assign sw_pkt1_3_0=swo[28];
    assign sw_pkt1_3_1=swo[29];
    assign sw_pkt1_3_2=swo[30];
    assign sw_pkt1_3_3=swo[31];

    sw_logic sw_logic_inst0(.wr(wr_ge[0]), 
                                       .rd(rd_ge[0]),
                                       .rst_n(rst_n_ge_w),
                                       .rst_upi_n(rst_upi_n),
                                       .clk_sw(clk_ge),
                                       .clk_cfig(clk_cfig),                                       
                                       .mode(mode_ge), 
                                       .if_addr(if_addr_g),
                                       .if_addr_upi(if_addr_upi),                                       
                                       .if_in(if_in_g), 
                                       .if_out(if_out_sg_0), 
                                       .cp(cp_0), 
                                       .pkt0(pkt0_0), 
                                       .pkt1(pkt1_0), 
                                       .crc_in(crc_in[0]),
                                       .crc_out(crc_0),
                                       .sw_pkt0_n_0(sw[0]), 
                                       .sw_pkt0_n_1(sw[1]), 
                                       .sw_pkt0_n_2(sw[2]), 
                                       .sw_pkt0_n_3(sw[3]), 
                                       .sw_pkt1_n_0(sw[4]), 
                                       .sw_pkt1_n_1(sw[5]), 
                                       .sw_pkt1_n_2(sw[6]), 
                                       .sw_pkt1_n_3(sw[7]));

    sw_logic sw_logic_inst1(.wr(wr_ge[1]), 
                                       .rd(rd_ge[1]), 
                                       .mode(mode_ge),
                                       .rst_n(rst_n_ge_w),
                                       .rst_upi_n(rst_upi_n),
                                       .clk_sw(clk_ge),
                                       .clk_cfig(clk_cfig), 
                                       .if_addr(if_addr_g),
                                       .if_addr_upi(if_addr_upi),                                           
                                       .if_in(if_in_g), 
                                       .if_out(if_out_sg_1), 
                                       .cp(cp_1), 
                                       .pkt0(pkt0_1), 
                                       .pkt1(pkt1_1), 
                                       .crc_in(crc_in[1]),
                                       .crc_out(crc_1),
                                       .sw_pkt0_n_0(sw[8]), 
                                       .sw_pkt0_n_1(sw[9]), 
                                       .sw_pkt0_n_2(sw[10]), 
                                       .sw_pkt0_n_3(sw[11]), 
                                       .sw_pkt1_n_0(sw[12]), 
                                       .sw_pkt1_n_1(sw[13]), 
                                       .sw_pkt1_n_2(sw[14]), 
                                       .sw_pkt1_n_3(sw[15]));

    sw_logic sw_logic_inst2(.wr(wr_fe[0]), 
                                       .rd(rd_fe[0]), 
                                       .mode(mode_fe),
                                       .rst_n(rst_n_fe_w),
                                       .rst_upi_n(rst_upi_n),
                                       .clk_sw(clk_fe),
                                       .clk_cfig(clk_cfig), 
                                       .if_addr(if_addr_f),
                                       .if_addr_upi(if_addr_upi),                                       
                                       .if_in(if_in_f), 
                                       .if_out(if_out_sg_2), 
                                       .cp(cp_2), 
                                       .pkt0(pkt0_2), 
                                       .pkt1(pkt1_2), 
                                       .crc_in(crc_in[2]),
                                       .crc_out(crc_2),
                                       .sw_pkt0_n_0(sw[16]), 
                                       .sw_pkt0_n_1(sw[17]), 
                                       .sw_pkt0_n_2(sw[18]), 
                                       .sw_pkt0_n_3(sw[19]), 
                                       .sw_pkt1_n_0(sw[20]), 
                                       .sw_pkt1_n_1(sw[21]), 
                                       .sw_pkt1_n_2(sw[22]), 
                                       .sw_pkt1_n_3(sw[23]));

    sw_logic sw_logic_inst3(.wr(wr_fe[1]), 
                                       .rd(rd_fe[1]), 
                                       .mode(mode_fe),
                                       .rst_n(rst_n_fe_w),
                                       .rst_upi_n(rst_upi_n),
                                       .clk_sw(clk_fe),
                                       .clk_cfig(clk_cfig), 
                                       .if_addr(if_addr_f),
                                       .if_addr_upi(if_addr_upi),                                       
                                       .if_in(if_in_f), 
                                       .if_out(if_out_sg_3), 
                                       .cp(cp_3), 
                                       .pkt0(pkt0_3), 
                                       .pkt1(pkt1_3),
                                       .crc_in(crc_in[3]),
                                       .crc_out(crc_3),
                                       .sw_pkt0_n_0(sw[24]), 
                                       .sw_pkt0_n_1(sw[25]), 
                                       .sw_pkt0_n_2(sw[26]), 
                                       .sw_pkt0_n_3(sw[27]), 
                                       .sw_pkt1_n_0(sw[28]), 
                                       .sw_pkt1_n_1(sw[29]), 
                                       .sw_pkt1_n_2(sw[30]), 
                                       .sw_pkt1_n_3(sw[31]));

                                       
    always@(rd_ge or rd_fe or if_out_sg_0 or if_out_sg_1 or if_out_sg_2 or if_out_sg_3)
    begin
        case({rd_fe, rd_ge})
        4'b0001: if_out=if_out_sg_0;
        4'b0010: if_out=if_out_sg_1;
        4'b0100: if_out=if_out_sg_2;
        4'b1000: if_out=if_out_sg_3;
        default: if_out=if_out_sg_0;
        endcase
    end    

    genvar i;                                                               // dff output
    generate
        for(i=0;i<=15;i=i+1)
            begin: pkt0_loop
                dff_80 dff_inst(.din(sw[i]), .qout(swo[i]), .rst_n(rst_n_ge_w), .clk(clk_ge));
             end
    endgenerate

    generate
        for(i=16;i<=31;i=i+1)
            begin: pkt1_loop
                dff_80 dff_inst(.din(sw[i]), .qout(swo[i]), .rst_n(rst_n_fe_w), .clk(clk_fe));
             end
    endgenerate

    always@(posedge clk_ge or negedge rst_n_ge_w)
    begin
        if(rst_n_ge_w==1'b0)
        begin
            crc_0_d<=4'b0;
            crc_1_d<=4'b0;
            valid[0]<=1'b0;
            valid[1]<=1'b0;
        end
        else
        begin
            crc_0_d<=crc_0;
            crc_1_d<=crc_1;
            valid[0]<=pkt0_0[79];
            valid[1]<=pkt0_1[79];
        end
    end
    
    always@(posedge clk_fe or negedge rst_n_fe_w)
    begin
        if(rst_n_fe_w==1'b0)
        begin
            crc_2_d<=4'b0;
            crc_3_d<=4'b0;
            valid[2]<=1'b0;
            valid[3]<=1'b0;
        end
        else
        begin
            crc_2_d<=crc_2;
            crc_3_d<=crc_3;
            valid[2]<=pkt0_2[79];
            valid[3]<=pkt0_3[79];
        end
    end

endmodule









//=====================================================================
// Project : ethernet switch
// File Name : eth_swt.v
// Description : top level, ethernet switch
// Designer : PAIMON
// Email :
// Tel :
//=====================================================================
// History:
// Date By Version Change Description
// 2015/ 7/6 1.0 Initial Release
//=====================================================================
module eth_swt(
    input clk_ge,
    input clk_fe,
    input clk_upi,
    input rst_n,
    input rst_upi_n,
    input [31:0] upi_d,
    input [15:0] upi_a,
    input upi_we,
    input upi_rd,
    output [31:0] upi_q,
    
    input data_valid_0,
    input [127:0] data_0,
    input [3:0] data_bytes_0,
    input sof_0,
    input eof_0,
    input [9:0] block_tag_0,
    
    input data_valid_1,
    input [127:0] data_1,
    input [3:0] data_bytes_1,
    input sof_1,
    input eof_1,
    input [9:0] block_tag_1,
    
    input data_valid_2,
    input [127:0] data_2,
    input [3:0] data_bytes_2,
    input sof_2,
    input eof_2,
    input [9:0] block_tag_2,
    
    input data_valid_3,
    input [127:0] data_3,
    input [3:0] data_bytes_3,
    input sof_3,
    input eof_3,
    input [9:0] block_tag_3,
    
    output switched_data_valid_0,
    output [63:0] switched_data_0,
    output [2:0] switched_data_bytes_0,
    output switched_sof_0,
    output switched_eof_0,
    output [9:0] switched_block_tag_0,
    
    output switched_data_valid_1,
    output [63:0] switched_data_1,
    output [2:0] switched_data_bytes_1,
    output switched_sof_1,
    output switched_eof_1,
    output [9:0] switched_block_tag_1,
    
    output switched_data_valid_2,
    output [63:0] switched_data_2,
    output [2:0] switched_data_bytes_2,
    output switched_sof_2,
    output switched_eof_2,
    output [9:0] switched_block_tag_2,
    
    output switched_data_valid_3,
    output [63:0] switched_data_3,
    output [2:0] switched_data_bytes_3,
    output switched_sof_3,
    output switched_eof_3,
    output [9:0] switched_block_tag_3
);

    wire clk_ge_wr;
    wire clk_fe_wr;
    wire clk_ge_rd;
    wire clk_fe_rd;
    
    wire mode_ge;
    wire mode_fe;

    wire [3:0] sw_valid;
    //wire [5:0] if_addr_g;
    //wire [5:0] if_addr_f;
    wire [5:0] if_addr_upi;
    wire [5:0] if_addr_upi_wr;
    wire [1:0] if_rd_g;
    wire [1:0] if_rd_f;
    wire [1:0] if_wr_g;
    wire [1:0] if_wr_f;    
    wire [31:0] con_data_in;
    wire [31:0] con_data_out;
    //wire [31:0] con_data_out_f;
    
    wire [1:0] cp_0;
    wire [1:0] cp_1;
    wire [1:0] cp_2;
    wire [1:0] cp_3;
    
    wire [3:0] sw_crc_in;
    wire [3:0] crc_0;
    wire [3:0] crc_1;
    wire [3:0] crc_2;
    wire [3:0] crc_3;
    wire [3:0] crc_err_0;
    wire [3:0] crc_err_1;
    wire [3:0] crc_err_2;
    wire [3:0] crc_err_3;
    
    wire  [1:0] loss_0_ge;
    wire  [1:0] loss_1_ge;
    wire  [1:0] loss_2_ge;
    wire  [1:0] loss_3_ge;
    wire  [1:0] loss_0_fe;
    wire  [1:0] loss_1_fe;
    wire  [1:0] loss_2_fe;
    wire  [1:0] loss_3_fe;
    
    wire  [1:0] error_0_ge;
    wire  [1:0] error_1_ge;
    wire  [1:0] error_2_ge;
    wire  [1:0] error_3_ge;
    wire  [1:0] error_0_fe;
    wire  [1:0] error_1_fe;
    wire  [1:0] error_2_fe;
    wire  [1:0] error_3_fe;
    
    wire  [1:0] last_0_ge;
    wire  [1:0] last_1_ge;
    wire  [1:0] last_2_ge;
    wire  [1:0] last_3_ge;
    wire  [1:0] last_0_fe;
    wire  [1:0] last_1_fe;
    wire  [1:0] last_2_fe;
    wire  [1:0] last_3_fe;
    
    wire  [1:0] valid_0_ge;
    wire  [1:0] valid_1_ge;
    wire  [1:0] valid_2_ge;
    wire  [1:0] valid_3_ge;
    wire  [1:0] valid_0_fe;
    wire  [1:0] valid_1_fe;
    wire  [1:0] valid_2_fe;
    wire  [1:0] valid_3_fe;
    
    wire rst_n_fe_r;
    wire rst_n_fe_w;
    wire rst_n_ge_r;
    wire rst_n_ge_w;
    wire rst_upi_n_syn;
    
    wire [79:0] ps_pkt0_0;
    wire [79:0] ps_pkt0_1;
    wire [79:0] ps_pkt0_2;
    wire [79:0] ps_pkt0_3;
    wire [79:0] ps_pkt1_0;
    wire [79:0] ps_pkt1_1;
    wire [79:0] ps_pkt1_2;
    wire [79:0] ps_pkt1_3;
    
    wire [79:0] sw_pkt0_0_0;
    wire [79:0] sw_pkt0_0_1;
    wire [79:0] sw_pkt0_0_2;
    wire [79:0] sw_pkt0_0_3;
    wire [79:0] sw_pkt1_0_0;
    wire [79:0] sw_pkt1_0_1;
    wire [79:0] sw_pkt1_0_2;
    wire [79:0] sw_pkt1_0_3;
    wire [79:0] sw_pkt0_1_0;
    wire [79:0] sw_pkt0_1_1;
    wire [79:0] sw_pkt0_1_2;
    wire [79:0] sw_pkt0_1_3;
    wire [79:0] sw_pkt1_1_0;
    wire [79:0] sw_pkt1_1_1;
    wire [79:0] sw_pkt1_1_2;
    wire [79:0] sw_pkt1_1_3;
    wire [79:0] sw_pkt0_2_0;
    wire [79:0] sw_pkt0_2_1;
    wire [79:0] sw_pkt0_2_2;
    wire [79:0] sw_pkt0_2_3;
    wire [79:0] sw_pkt1_2_0;
    wire [79:0] sw_pkt1_2_1;
    wire [79:0] sw_pkt1_2_2;
    wire [79:0] sw_pkt1_2_3;
    wire [79:0] sw_pkt0_3_0;
    wire [79:0] sw_pkt0_3_1;
    wire [79:0] sw_pkt0_3_2;
    wire [79:0] sw_pkt0_3_3;
    wire [79:0] sw_pkt1_3_0;
    wire [79:0] sw_pkt1_3_1;
    wire [79:0] sw_pkt1_3_2;
    wire [79:0] sw_pkt1_3_3;
    
    assign clk_fe_rd=clk_fe;
    assign clk_ge_rd=clk_ge;
    assign crc_err_0[0]=crc_0[0];
    assign crc_err_0[1]=crc_1[0];
    assign crc_err_0[2]=crc_2[0];
    assign crc_err_0[3]=crc_3[0];
    assign crc_err_1[0]=crc_0[1];
    assign crc_err_1[1]=crc_1[1];
    assign crc_err_1[2]=crc_2[1];
    assign crc_err_1[3]=crc_3[1];
    assign crc_err_2[0]=crc_0[2];
    assign crc_err_2[1]=crc_1[2];
    assign crc_err_2[2]=crc_2[2];
    assign crc_err_2[3]=crc_3[2];
    assign crc_err_3[0]=crc_0[3];
    assign crc_err_3[1]=crc_1[3];
    assign crc_err_3[2]=crc_2[3];
    assign crc_err_3[3]=crc_3[3];
    
    rst_n_syner rst_n_syner_inst_0(.clk(clk_ge_wr),
                                   .rst_n(rst_n),
                                   .rst_n_syn(rst_n_ge_w)
                                   );
    rst_n_syner rst_n_syner_inst_1(.clk(clk_fe_wr),
                                   .rst_n(rst_n),
                                   .rst_n_syn(rst_n_fe_w)
                                   );
    rst_n_syner rst_n_syner_inst_2(.clk(clk_ge_rd),
                                   .rst_n(rst_n),
                                   .rst_n_syn(rst_n_ge_r)
                                   );
    rst_n_syner rst_n_syner_inst_3(.clk(clk_fe_rd),
                                   .rst_n(rst_n),
                                   .rst_n_syn(rst_n_fe_r)
                                   );    
    rst_n_syner rst_n_syner_inst_4(.clk(clk_upi),
                                   .rst_n(rst_upi_n),
                                   .rst_n_syn(rst_upi_n_syn)
                                   );                           
    
    clk clk_inst(.clk_ge(clk_ge),
                 .clk_fe(clk_fe),
                 .rst_n(rst_n),
                 .clk_ge2(clk_ge_wr),
                 .clk_fe2(clk_fe_wr));
                 
    pkt_spl pkt_spl_inst(.clk_fe(clk_fe_wr),
                         .clk_ge(clk_ge_wr),
                         .rst_n_ge_w(rst_n_ge_w),
                         .rst_n_fe_w(rst_n_fe_w),
                         .data_valid_0(data_valid_0),
                         .data_0(data_0),
                         .data_bytes_0(data_bytes_0),
                         .sof_0(sof_0),
                         .eof_0(eof_0),
                         .block_tag_0(block_tag_0),
                         .ps_pkt0_0(ps_pkt0_0),
                         .ps_pkt1_0(ps_pkt1_0),
                         .data_valid_1(data_valid_1),
                         .data_1(data_1),
                         .data_bytes_1(data_bytes_1),
                         .sof_1(sof_1),
                         .eof_1(eof_1),
                         .block_tag_1(block_tag_1),
                         .ps_pkt0_1(ps_pkt0_1),
                         .ps_pkt1_1(ps_pkt1_1),
                         .data_valid_2(data_valid_2),
                         .data_2(data_2),
                         .data_bytes_2(data_bytes_2),
                         .sof_2(sof_2),
                         .eof_2(eof_2),
                         .block_tag_2(block_tag_2),
                         .ps_pkt0_2(ps_pkt0_2),
                         .ps_pkt1_2(ps_pkt1_2),
                         .data_valid_3(data_valid_3),
                         .data_3(data_3),
                         .data_bytes_3(data_bytes_3),
                         .sof_3(sof_3),
                         .eof_3(eof_3),
                         .block_tag_3(block_tag_3),
                         .ps_pkt0_3(ps_pkt0_3),
                         .ps_pkt1_3(ps_pkt1_3)
                         );
                         
    switches switches_inst(
                         .mode_ge(mode_ge),                    //from config
                         .mode_fe(mode_fe),
                         .rst_n_ge_w(rst_n_ge_w),
                         .rst_n_fe_w(rst_n_fe_w),
                         .rst_upi_n(rst_upi_n_syn),
                         .clk_ge(clk_ge_wr),
                         .clk_fe(clk_fe_wr),
                         .clk_cfig(clk_upi),
                         .wr_ge(if_wr_g),                          //from config
                         .wr_fe(if_wr_f),
                         .rd_ge(if_rd_g),                          //config
                         .rd_fe(if_rd_f),
                         .pkt0_0(ps_pkt0_0),
                         .pkt1_0(ps_pkt1_0),
                         .pkt0_1(ps_pkt0_1),
                         .pkt1_1(ps_pkt1_1),
                         .pkt0_2(ps_pkt0_2),
                         .pkt1_2(ps_pkt1_2),
                         .pkt0_3(ps_pkt0_3),
                         .pkt1_3(ps_pkt1_3),
                         .cp_0(cp_0),                      //config
                         .cp_1(cp_1),
                         .cp_2(cp_2),
                         .cp_3(cp_3),
                         .if_addr_g(if_addr_upi_wr),
                         .if_addr_f(if_addr_upi_wr),
                         .if_addr_upi(if_addr_upi),
                         .if_in_g(con_data_out),
                         .if_in_f(con_data_out),
                         .crc_in(sw_crc_in),
                         .if_out(con_data_in),
                         .valid(sw_valid),                       //output to config
                         .sw_pkt0_0_0(sw_pkt0_0_0),
                         .sw_pkt0_0_1(sw_pkt0_0_1),
                         .sw_pkt0_0_2(sw_pkt0_0_2),
                         .sw_pkt0_0_3(sw_pkt0_0_3),
                         .sw_pkt1_0_0(sw_pkt1_0_0),
                         .sw_pkt1_0_1(sw_pkt1_0_1),
                         .sw_pkt1_0_2(sw_pkt1_0_2),
                         .sw_pkt1_0_3(sw_pkt1_0_3),
                         .sw_pkt0_1_0(sw_pkt0_1_0),
                         .sw_pkt0_1_1(sw_pkt0_1_1),
                         .sw_pkt0_1_2(sw_pkt0_1_2),
                         .sw_pkt0_1_3(sw_pkt0_1_3),
                         .sw_pkt1_1_0(sw_pkt1_1_0),
                         .sw_pkt1_1_1(sw_pkt1_1_1),
                         .sw_pkt1_1_2(sw_pkt1_1_2),
                         .sw_pkt1_1_3(sw_pkt1_1_3),
                         .sw_pkt0_2_0(sw_pkt0_2_0),
                         .sw_pkt0_2_1(sw_pkt0_2_1),
                         .sw_pkt0_2_2(sw_pkt0_2_2),
                         .sw_pkt0_2_3(sw_pkt0_2_3),
                         .sw_pkt1_2_0(sw_pkt1_2_0),
                         .sw_pkt1_2_1(sw_pkt1_2_1),
                         .sw_pkt1_2_2(sw_pkt1_2_2),
                         .sw_pkt1_2_3(sw_pkt1_2_3),
                         .sw_pkt0_3_0(sw_pkt0_3_0),
                         .sw_pkt0_3_1(sw_pkt0_3_1),
                         .sw_pkt0_3_2(sw_pkt0_3_2),
                         .sw_pkt0_3_3(sw_pkt0_3_3),
                         .sw_pkt1_3_0(sw_pkt1_3_0),
                         .sw_pkt1_3_1(sw_pkt1_3_1),
                         .sw_pkt1_3_2(sw_pkt1_3_2),
                         .sw_pkt1_3_3(sw_pkt1_3_3),
                         .crc_0_d(crc_0),                   // output to fifo
                         .crc_1_d(crc_1),
                         .crc_2_d(crc_2),
                         .crc_3_d(crc_3)
                         );
                         
    fifo_groups fifo_groups_inst(.clk_ge_wr(clk_ge_wr),
                                   .clk_fe_wr(clk_fe_wr),
                                   .clk_ge_rd(clk_ge_rd),
                                   .clk_fe_rd(clk_fe_rd),
                                   .rst_n_ge_w(rst_n_ge_w),
                                   .rst_n_fe_w(rst_n_fe_w),
                                   .rst_n_ge_r(rst_n_ge_r),
                                   .rst_n_fe_r(rst_n_fe_r),
                                   .crc_err_0(crc_err_0),
                                   .crc_err_1(crc_err_1),
                                   .crc_err_2(crc_err_2),
                                   .crc_err_3(crc_err_3),
                                   .pkt0_0_0(sw_pkt0_0_0),
                                   .pkt0_1_0(sw_pkt0_1_0),
                                   .pkt0_2_0(sw_pkt0_2_0),
                                   .pkt0_3_0(sw_pkt0_3_0),
                                   .pkt1_0_0(sw_pkt1_0_0),
                                   .pkt1_1_0(sw_pkt1_1_0),
                                   .pkt1_2_0(sw_pkt1_2_0),
                                   .pkt1_3_0(sw_pkt1_3_0),
                                   .pkt0_0_1(sw_pkt0_0_1),
                                   .pkt0_1_1(sw_pkt0_1_1),
                                   .pkt0_2_1(sw_pkt0_2_1),
                                   .pkt0_3_1(sw_pkt0_3_1),
                                   .pkt1_0_1(sw_pkt1_0_1),
                                   .pkt1_1_1(sw_pkt1_1_1),
                                   .pkt1_2_1(sw_pkt1_2_1),
                                   .pkt1_3_1(sw_pkt1_3_1),
                                   .pkt0_0_2(sw_pkt0_0_2),
                                   .pkt0_1_2(sw_pkt0_1_2),
                                   .pkt0_2_2(sw_pkt0_2_2),
                                   .pkt0_3_2(sw_pkt0_3_2),
                                   .pkt1_0_2(sw_pkt1_0_2),
                                   .pkt1_1_2(sw_pkt1_1_2),
                                   .pkt1_2_2(sw_pkt1_2_2),
                                   .pkt1_3_2(sw_pkt1_3_2),
                                   .pkt0_0_3(sw_pkt0_0_3),
                                   .pkt0_1_3(sw_pkt0_1_3),
                                   .pkt0_2_3(sw_pkt0_2_3),
                                   .pkt0_3_3(sw_pkt0_3_3),
                                   .pkt1_0_3(sw_pkt1_0_3),
                                   .pkt1_1_3(sw_pkt1_1_3),
                                   .pkt1_2_3(sw_pkt1_2_3),
                                   .pkt1_3_3(sw_pkt1_3_3),
                                   .loss_0_ge(loss_0_ge),
                                   .loss_1_ge(loss_1_ge),
                                   .loss_2_ge(loss_2_ge),
                                   .loss_3_ge(loss_3_ge),
                                   .loss_0_fe(loss_0_fe),
                                   .loss_1_fe(loss_1_fe),
                                   .loss_2_fe(loss_2_fe),
                                   .loss_3_fe(loss_3_fe),
                                   .error_0_ge(error_0_ge),
                                   .error_1_ge(error_1_ge),
                                   .error_2_ge(error_2_ge),
                                   .error_3_ge(error_3_ge),
                                   .error_0_fe(error_0_fe),
                                   .error_1_fe(error_1_fe),
                                   .error_2_fe(error_2_fe),
                                   .error_3_fe(error_3_fe),
                                   .last_0_ge(last_0_ge),
                                   .last_1_ge(last_1_ge),
                                   .last_2_ge(last_2_ge),
                                   .last_3_ge(last_3_ge),
                                   .last_0_fe(last_0_fe),
                                   .last_1_fe(last_1_fe),
                                   .last_2_fe(last_2_fe),
                                   .last_3_fe(last_3_fe),
                                   .valid_0_ge(valid_0_ge),
                                   .valid_1_ge(valid_1_ge),
                                   .valid_2_ge(valid_2_ge),
                                   .valid_3_ge(valid_3_ge),
                                   .valid_0_fe(valid_0_fe),
                                   .valid_1_fe(valid_1_fe),
                                   .valid_2_fe(valid_2_fe),
                                   .valid_3_fe(valid_3_fe),
                                   .switched_data_valid_0(switched_data_valid_0),
                                   .switched_data_0(switched_data_0),
                                   .switched_data_bytes_0(switched_data_bytes_0),
                                   .switched_sof_0(switched_sof_0),
                                   .switched_eof_0(switched_eof_0),
                                   .switched_block_tag_0(switched_block_tag_0),
                                   .switched_data_valid_1(switched_data_valid_1),
                                   .switched_data_1(switched_data_1),
                                   .switched_data_bytes_1(switched_data_bytes_1),
                                   .switched_sof_1(switched_sof_1),
                                   .switched_eof_1(switched_eof_1),
                                   .switched_block_tag_1(switched_block_tag_1),
                                   .switched_data_valid_2(switched_data_valid_2),
                                   .switched_data_2(switched_data_2),
                                   .switched_data_bytes_2(switched_data_bytes_2),
                                   .switched_sof_2(switched_sof_2),
                                   .switched_eof_2(switched_eof_2),
                                   .switched_block_tag_2(switched_block_tag_2),
                                   .switched_data_valid_3(switched_data_valid_3),
                                   .switched_data_3(switched_data_3),
                                   .switched_data_bytes_3(switched_data_bytes_3),
                                   .switched_sof_3(switched_sof_3),
                                   .switched_eof_3(switched_eof_3),
                                   .switched_block_tag_3(switched_block_tag_3)
                                   );

    confi confi_inst(.sw_valid(sw_valid),
                     .upi_a(upi_a),
                     .upi_we(upi_we),
                     .upi_rd(upi_rd),
                     .clk_upi(clk_upi),
                     .rst_n_ge(rst_n_ge_w),
                     .rst_n_fe(rst_n_fe_w),
                     .rst_upi_n(rst_upi_n_syn),
                     .upi_d(upi_d),
                     .loss_0_ge(loss_0_ge),
                     .loss_1_ge(loss_1_ge),
                     .loss_2_ge(loss_2_ge),
                     .loss_3_ge(loss_3_ge),
                     .loss_0_fe(loss_0_fe),
                     .loss_1_fe(loss_1_fe),
                     .loss_2_fe(loss_2_fe),
                     .loss_3_fe(loss_3_fe),
                     .error_0_ge(error_0_ge),
                     .error_1_ge(error_1_ge),
                     .error_2_ge(error_2_ge),
                     .error_3_ge(error_3_ge),
                     .error_0_fe(error_0_fe),
                     .error_1_fe(error_1_fe),
                     .error_2_fe(error_2_fe),
                     .error_3_fe(error_3_fe),
                     .last_0_ge(last_0_ge),
                     .last_1_ge(last_1_ge),
                     .last_2_ge(last_2_ge),
                     .last_3_ge(last_3_ge),
                     .last_0_fe(last_0_fe),
                     .last_1_fe(last_1_fe),
                     .last_2_fe(last_2_fe),
                     .last_3_fe(last_3_fe),
                     .valid_0_ge(valid_0_ge),
                     .valid_1_ge(valid_1_ge),
                     .valid_2_ge(valid_2_ge),
                     .valid_3_ge(valid_3_ge),
                     .valid_0_fe(valid_0_fe),
                     .valid_1_fe(valid_1_fe),
                     .valid_2_fe(valid_2_fe),
                     .valid_3_fe(valid_3_fe),
                     .clk_ge(clk_ge_wr),
                     .clk_fe(clk_fe_wr),
                     .con_data_in(con_data_in),
                     .con_data_out(con_data_out),
                     //.con_data_out_f(con_data_out_f),
                     .upi_q(upi_q),
                     //.if_addr_g(if_addr_g),
                     //.if_addr_f(if_addr_f),
                     .if_addr_upi(if_addr_upi),
                     .if_addr_upi_wr(if_addr_upi_wr),
                     .if_wr_g(if_wr_g),
                     .if_wr_f(if_wr_f),
                     .if_rd_g(if_rd_g),
                     .if_rd_f(if_rd_f),
                     .cp_0(cp_0),
                     .cp_1(cp_1),
                     .cp_2(cp_2),
                     .cp_3(cp_3),
                     .mode_ge(mode_ge),
                     .mode_fe(mode_fe)
                     );
                     
    crc32 crc32_inst_0(.clk(clk_ge_wr),
                         .rst_n(rst_n_ge_w),
                         .data(data_0),
                         .first(sof_0),
                         .last(eof_0),
                         .valid(data_valid_0),
                         .bytes(data_bytes_0),
                         .error(sw_crc_in[0]));
                 
    crc32 crc32_inst_1(.clk(clk_ge_wr),
                         .rst_n(rst_n_ge_w),
                         .data(data_1),
                         .first(sof_1),
                         .last(eof_1),
                         .valid(data_valid_1),
                         .bytes(data_bytes_1),
                         .error(sw_crc_in[1]));

    crc32 crc32_inst_2(.clk(clk_fe_wr),
                         .rst_n(rst_n_fe_w),
                         .data(data_2),
                         .first(sof_2),
                         .last(eof_2),
                         .valid(data_valid_2),
                         .bytes(data_bytes_2),
                         .error(sw_crc_in[2]));

    crc32 crc32_inst_3(.clk(clk_fe_wr),
                         .rst_n(rst_n_fe_w),
                         .data(data_3),
                         .first(sof_3),
                         .last(eof_3),
                         .valid(data_valid_3),
                         .bytes(data_bytes_3),
                         .error(sw_crc_in[3]));                         
                         
endmodule                         









module rst_n_syner(
    input rst_n,
    input clk,
    output reg rst_n_syn
);

    reg rst_n_d1;
    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            rst_n_syn<=1'b0;
        else 
            rst_n_syn<=rst_n_d1;
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            rst_n_d1<=1'b0;
        else 
            rst_n_d1<=1'b1;
    end
    
endmodule




module synch(
    input rst_n,
    input clk,
    input data_a,
    output reg data_s
);

    reg data_d1;
    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            data_s<=1'b0;
        else 
            data_s<=data_d1;
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            data_d1<=1'b0;
        else 
            data_d1<=data_a;
    end
    
endmodule





module pulse_synch(
    input clk_a,
    input clk_b,
    input rst_n_a,
    input rst_n_b,
    input data_a,
    output data_s
);

    wire d1;

    reg q1;
    reg q1_b; 
    reg q2;
    reg q3;
    reg q4;
    
    assign d1=data_a?q1_b:q1;
    assign data_s=q3^q4;
    
    always@(posedge clk_a or negedge rst_n_a)
    begin
        if(rst_n_a==1'b0)
        begin
            q1<=1'b0;
            q1_b<=1'b1;
        end
        else
        begin
            q1<=d1;
            q1_b<=~d1;
        end
    end
    
    always@(posedge clk_b or negedge rst_n_b)
    begin
        if(rst_n_b==1'b0)
        begin
            q2<=1'b0;
            q3<=1'b0;
            q4<=1'b0;
        end
        else
        begin
            q2<=q1;
            q3<=q2;
            q4<=q3;
        end
    end

 endmodule




