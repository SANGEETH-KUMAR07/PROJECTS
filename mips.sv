module mips #(
   parameter WIDTH=32
 ) (
   clk,reset,inst,pc_out,aluout,memout
 );
 input clk,reset;
 output [WIDTH-1:0] pc_out,inst,memout;
 inout [WIDTH-1:0] aluout;
 wire [WIDTH-1:0] datao,memo;
 wire wmem ;
 cpu_datapath main(inst,memo,reset,clk,
   pc_out,aluout,datao, wmem);
 instruction_memory ins(pc_out,inst);
 datamemo data(aluout,datao,wmem,clk,
   memout);
   //clk,memout,data,aluout,wmem);
   // (clk,dataout,datain,addr,we);
   // address,datain,we,clk,
   //dataout
 endmodule
