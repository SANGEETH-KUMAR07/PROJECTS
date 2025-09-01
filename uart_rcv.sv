`timescale 1ns/1ps


module uart_rcv #(
    parameter wordsize=8
 ) (
    data_regr,error1,error2,read_not_ready_out,
    serial_in,read_not_ready_in,
    sclk,reset
 );
 output [wordsize-1:0] data_regr;
 output error1,error2,read_not_ready_out;
 input serial_in,read_not_ready_in,sclk,reset;

 wire load_rcvshft_reg,load_rcvdata_reg;
 wire [2:0] sample_counter;
 wire [3:0] bit_counter;
 wire inc_sample_counter,clr_sample_counter,clr_bit_counter,inc_bit_counter,shift,load;

 rcv_controller m0(read_not_ready_out,error1,error2,
                    inc_sample_counter,clr_sample_counter,clr_bit_counter,
                    inc_bit_counter,shift,load,
                    sample_counter,bit_counter,
                    serial_in,read_not_ready_in,sclk,reset);

 rcv_datapath m1(data_regr,sample_counter,bit_counter,
                    serial_in,inc_sample_counter,clr_sample_counter,
                    clr_bit_counter,inc_bit_counter,shift,load,
                    sclk,reset);
    
 endmodule

module rcv_controller #(
    parameter wordsize=8
 ) (
                    read_not_ready_out,error1,error2,
                    inc_sample_counter,clr_sample_counter,clr_bit_counter,
                    inc_bit_counter,shift,load,
                    sample_counter,bit_counter,
                    serial_in,read_not_ready_in,sclk,reset 
 );
 output reg         read_not_ready_out,error1,error2,
                    inc_sample_counter,clr_sample_counter,clr_bit_counter,
                    inc_bit_counter,shift,load;
 input serial_in,read_not_ready_in,sclk,reset;
 input [2:0] sample_counter;
 input [3:0] bit_counter;
 
 reg[1:0] state,next_state;
 parameter idle=0,starting=1,receiving=2;

 always @(posedge sclk,negedge reset) begin
    if(reset==0) state<=idle;
    else state<=next_state;
 end

 always @(state,serial_in,sample_counter,bit_counter,read_not_ready_in) begin
    read_not_ready_out=0;           error1=0;               error2=0;
    inc_sample_counter=0;       clr_sample_counter=0;       clr_bit_counter=0;
    inc_bit_counter=0;          shift=0;                    load=0;
    next_state=state;
    case (state)
        idle:begin
            if(serial_in==0) next_state=starting;
        end 
        starting:begin
            if(serial_in) begin
                clr_sample_counter=1;
                next_state=idle;
            end
            else begin
                if(sample_counter==3)begin
                    clr_sample_counter=1;
                    next_state=receiving;
                end
                else inc_sample_counter=1;
            end
        end
        receiving:begin
            inc_sample_counter=1;
            if(sample_counter==7)begin
                if(bit_counter==8)begin
                    read_not_ready_out=1;
                    clr_sample_counter=1;
                    clr_bit_counter=1;
                    if(read_not_ready_in)begin
                        error1=1;
                        next_state=idle;
                    end
                    else begin
                        next_state=idle;
                        if(serial_in==0) error2=1;
                        else load=1;
                    end
                end
                else begin
                    shift=1;
                    inc_bit_counter=1;
                    inc_sample_counter=1;
                end
            end
            else next_state=receiving;
        end
        default: next_state=idle; 
    endcase
 end
   
 endmodule

module rcv_datapath #(
    parameter wordsize=8
 )                  (data_regr,sample_counter,bit_counter,
                    serial_in,inc_sample_counter,clr_sample_counter,
                    clr_bit_counter,inc_bit_counter,shift,load,
                    sclk,reset);

  output reg[wordsize-1:0] data_regr;
  output reg[2:0] sample_counter;
  output reg[3:0] bit_counter;

  input serial_in,inc_sample_counter,clr_sample_counter;
  input clr_bit_counter,inc_bit_counter,shift,load,sclk,reset;
  
  reg [wordsize-1:0]rcv_shftreg;

  always @(posedge sclk,negedge reset) begin
    if(reset==0) begin
        data_regr<=0;
        sample_counter<=0;
        bit_counter<=0;
        rcv_shftreg<=0;
    end
    else begin
        if(inc_sample_counter) sample_counter<=sample_counter+1;
        if(inc_bit_counter) bit_counter<=bit_counter+1;
        if(clr_bit_counter) bit_counter<=0;
        if(clr_sample_counter) sample_counter<=0;
        if(shift) rcv_shftreg<={serial_in,rcv_shftreg[7:1]};
        if(load) data_regr<=rcv_shftreg;
    end
  end
    
 endmodule

/*module t_rcv #(
    parameter wordsize=8
 ) ();
 wire  [wordsize-1:0] data_regr;
 wire  error1,error2,read_not_ready_out;
 reg serial_in,read_not_ready_in,sclk,reset;
  
  uart_rcv m2( data_regr,error1,error2,read_not_ready_out,
    serial_in,read_not_ready_in,
    sclk,reset);

 initial begin
    sclk=0;
    forever #5 sclk=~sclk;
 end   
 initial begin
    read_not_ready_in=0;
    #4 reset=0;
    #9 reset=1;
    #4 serial_in=1;
    #80 serial_in=0;

    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=1;

    #80 serial_in=1;
    

    #80 serial_in=0;

    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=0;

    #80 serial_in=0;

    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=1;

    #80 serial_in=1;
    read_not_ready_in=1;
    
    #20 read_not_ready_in=0;

    #80 serial_in=0;

    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=1;
    #80 serial_in=1;

    #80 serial_in=1; 



    #80 serial_in=0;

    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=1;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=0;
    #80 serial_in=1;

    #80 serial_in=1;


    #200 $finish;
 end

 initial begin
    $dumpfile("rcv.vcd");
    $dumpvars(0);
 end

 
    
endmodule
*/
