module datamemo #(
   parameter WIDTH=32,LENGTH=32
 ) (
   address,datain,we,clk,
   dataout
 );
 input [WIDTH-1:0] address,datain;
 input we,clk;
 output [WIDTH-1:0] dataout;

 reg [WIDTH-1:0] datamem [0:LENGTH-1];

 assign dataout =datamem[address[6:2]];

 always @(posedge clk) begin
   if(we) datamem[address[6:2]]<=datain;
 end
 initial begin
   for (integer i =0 ;i<LENGTH ;i++ ) begin
      datamem[i]=0;
   end
   // datamem[word_addr] = data // (byte_addr) item in data array
 datamem[5'h14] = 32'h000000a3; // (50) data[0] 0 + A3 = A3
 datamem[5'h15] = 32'h00000027; // (54) data[1] a3 + 27 = ca
 datamem[5'h16] = 32'h00000079; // (58) data[2] ca + 79 = 143
 datamem[5'h17] = 32'h00000115; // (5c) data[3] 143 + 115 = 258
 // datamem[5’h18] should be 0x00000258, the sum stored by sw instruction
 end
   
 endmodule
