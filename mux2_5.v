 module mux2_5(
   a1,b1,select1,output1
 );
 input [4:0] a1,b1;
 input select1;
 output  [4:0] output1;
 assign output1 = select1 ? b1:a1; 
   
 endmodule
