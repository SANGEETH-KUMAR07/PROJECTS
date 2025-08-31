module regfile #(
    parameter LENGTH=32 , ADDR=5, WIDTH=32 
 ) (
    read_source1,read_source2,write_address,write_data,write_enable,clk,reset,
    read_data1,read_data2
 );
 input [ADDR-1:0] read_source1,read_source2,write_address;
 input [WIDTH-1:0] write_data;
 input write_enable,clk,reset;
 output [WIDTH-1:0] read_data1,read_data2;
 
 reg [WIDTH-1:0] regband [LENGTH-1:0] ;
 
 assign read_data1 =(read_source1==0)?(WIDTH'(0)):regband[read_source1];
 assign read_data2 =(read_source2==0)?(WIDTH'(0)):regband[read_source2];
 
 always @(posedge clk,negedge reset) begin
    if(reset)begin
        for (int i =0 ;i<LENGTH ;i++ ) begin
            regband[i]<=0;
        end
    end
    else if(write_enable&&(write_address!=0)) regband[write_address]<= write_data;
 end
 endmodule

/* module regt #(
    parameter LENGTH=32,ADDR=5,WIDTH=32
 ) ();
 reg  [ADDR-1:0] read_source1,read_source2,write_address;
 reg [WIDTH-1:0] write_data;
 reg  write_enable,clk,reset;
 wire  [WIDTH-1:0] read_data1,read_data2;
 
 regfile m1(read_source1,read_source2,write_address,write_data,write_enable,clk,reset,
    read_data1,read_data2);
 initial begin
    clk=0;
    forever #5 clk=~clk;
 end    
 initial begin
    write_data=9;read_source1=0;read_source2=0;write_address=0;write_enable=1;
    #8 reset=1;
    #10 reset=0;
    write_enable=1;
    for (int i =0 ;i<LENGTH ;i++ ) begin
        #10 write_address=i;
            write_data= $random();
    end
    write_enable=0;
   for (int j =0 ;j<LENGTH ;j++ ) begin
       #5 read_source1=j;
          read_source2=LENGTH-1-j;
   end
   #50
   reset=1;
   #10 reset=0;
   for (int k =0 ;k<LENGTH ;k++ ) begin
       #5 read_source1=k;
          read_source2=LENGTH-1-k;
   end

  #20 $finish;
 end
 initial begin
    $dumpfile("reg.vcd");
    $dumpvars(0,regt);
 end
    
 endmodule */ 
