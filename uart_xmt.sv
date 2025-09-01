`timescale 1ns/1ps

module uart_xmt #(
    parameter wordsize=8
 ) (
    serial_out,
    data_in,load_xmtdata_reg,byte_ready,t_byte,
    clk,reset,enablex
 );

 output serial_out;
 input[wordsize-1:0] data_in;
 input load_xmtdata_reg,byte_ready,t_byte,clk,reset,enablex;

 wire start,shift,clear,load_xmtshftreg;
 wire[3:0] bit_count;

 uart_xmt_controller m0(load_xmtshftreg,start,shift,clear,bit_count,byte_ready,t_byte,clk,reset,enablex);

 uart_xmt_datapath m1(serial_out,bit_count,data_in,load_xmtdata_reg,load_xmtshftreg,start,shift,clear,clk,reset,enablex);
    
 endmodule

module uart_xmt_controller #(
    parameter wordsize=8
 ) (
    load_xmtshftreg,start,shift,clear,bit_count,byte_ready,t_byte,clk,reset,enablex
 );
 output reg load_xmtshftreg,start,shift,clear;
 input[3:0] bit_count;
 input byte_ready,t_byte,clk,reset,enablex;

 reg [1:0] state ,next_state; 
 parameter idle=0,waiting=1,sending=2;
 
 always @(posedge clk,negedge reset) begin
    if(reset==0) state<=idle;
    else if(enablex) state<=next_state;
 end
 always @(state,bit_count,byte_ready,t_byte) begin
   
        load_xmtshftreg=0;
        start=0;
        shift=0;
        clear=0;
   
        case (state)
            idle:begin
                if(byte_ready)begin
                    load_xmtshftreg=1;
                    next_state=waiting;
                end
                
            end 

            waiting:begin
                if(t_byte)begin
                    start=1;
                    next_state=sending;
                end
                
            end
            sending:begin
                if(bit_count==9)begin
                    clear=1;
                    next_state=idle;
                end
                else begin
                    shift=1;
                    
                end
            end
            default: next_state=idle;
        endcase
    end
 
    
 endmodule

module uart_xmt_datapath #(
    parameter wordsize=8
 ) (
    serial_out,bit_count,data_in,load_xmtdata_reg,load_xmtshftreg,start,shift,clear,clk,reset,enablex
 );
 output serial_out;
 output reg [3:0] bit_count;
 input [wordsize-1:0] data_in;
 input load_xmtdata_reg,load_xmtshftreg,start,shift,clear,clk,reset,enablex;
 reg[wordsize-1:0] xmt_datareg;
 reg[wordsize:0] xmt_shiftreg;

 parameter all_ones=9'h1ff,one=1'b1;

 assign serial_out=xmt_shiftreg[0];

 always @(posedge clk,negedge reset) begin
    if(reset==0) begin
        bit_count<=0;
        xmt_datareg<=0;
        xmt_shiftreg<=all_ones;
    end
    else if(enablex)begin
        if(load_xmtdata_reg) xmt_datareg<=data_in;
        if(load_xmtshftreg) xmt_shiftreg<={xmt_datareg,one};
        if(start) xmt_shiftreg[0]<=0;
        if(shift)begin
            xmt_shiftreg<={1'b1,xmt_shiftreg[wordsize:1]};
            bit_count<=bit_count+1;
        end
        if(clear) bit_count<=0;
    end
 end
    
 endmodule

/*module t_uart #(
    parameter wordsize=8
 ) (

 );
 wire serial_out;
 logic [wordsize-1:0]sent_out=0;
 reg [wordsize-1:0]data_in;
 reg load_xmtdata_reg,byte_ready,t_byte,clk,reset,enablex;
 

 uart_xmt m3(serial_out,
    data_in,load_xmtdata_reg,byte_ready,t_byte,
    clk,reset,enablex);

 always @(posedge clk) begin
    begin sent_out<= {serial_out,sent_out[7:1]};
                                
    end
  
 end   

 initial begin
    clk=0;
    forever #5 clk=~clk;
 end   
 initial begin
    enablex=1;
    data_in=8'ha7;
    reset=1;
    #5 reset=0;
    #5 reset=1;
    #9 load_xmtdata_reg=1;
    #12 load_xmtdata_reg=0;
    #15 byte_ready=1;
    #12 byte_ready=0;
    #20 t_byte=1;
    #12 t_byte=0;
        data_in=8'h57;

    #100 load_xmtdata_reg=1;
    #12 load_xmtdata_reg=0;
    #15 byte_ready=1;
    #12 byte_ready=0;
    #20 t_byte=1;
    #12 t_byte=0;  
    #200 $finish;
 end
 initial begin
    $dumpfile("uat.vcd");
    $dumpvars(0,t_uart);
 end
    
endmodule*/