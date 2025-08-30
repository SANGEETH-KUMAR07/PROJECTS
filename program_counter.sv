module program_counter #(
    parameter WIDTH=32 
 ) (
     pc_in,dis,
    clk,reset,
    pc_out,
   p4,bpc 
 );

 input [WIDTH-1:0] pc_in,dis;
    input clk,reset;
    output reg [WIDTH-1:0] pc_out;
    output [WIDTH-1:0] p4,bpc ;

 always @(posedge clk) begin
    if(reset) pc_out<=32'h00000000;
    else pc_out<=pc_in;
 end

 assign p4=pc_out+4;
 assign bpc=p4+dis;

    
 endmodule
