module mux4_32 #(
   parameter WIDTH=32 
 ) (
   a3,b3,c3,d3,select3,output3
 );
 input [WIDTH-1:0] a3,b3,c3,d3;
 input [1:0] select3;
 output reg [WIDTH-1:0] output3;
 always @(*) begin
    case (select3)
      2'b00 : output3=a3; 
      2'b01 : output3=b3; 
      2'b10 : output3=c3; 
      2'b11 : output3=d3; 

    endcase
 end 
   
 endmodule 
