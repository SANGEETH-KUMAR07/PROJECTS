module mux2_32 #(
   parameter WIDTH=32 
 ) (
   a2,b2,select2,output2
 );
 input [WIDTH-1:0] a2,b2;
 input select2;
 output [WIDTH-1:0] output2;
 assign output2 =select2 ?b2:a2; 
   
 endmodule
