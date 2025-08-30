module cpu_datapath #(
   parameter WIDTH=32 
 ) (
   inst,memo,reset,clk,
   pc_out,aluout,datao, wmem
 );
 input [WIDTH-1:0] inst,memo;
 input reset,clk;
 output [WIDTH-1:0]   pc_out,aluout,datao;
 output wmem;
 // instruction fields
 wire [5:0] op =inst[31:26];
 wire [5:0] func=inst[05:00];
 wire [4:0] rs=inst[25:21];
 wire [4:0] rt=inst[20:16];
 wire [4:0] rd=inst[15:11];
 wire [15:0] imm=inst[15:0];
 wire [25:0] addr=inst[25:0];
 //control signals
 wire [3:0] aluc ;
 wire [1:0] pcsrc;
 wire wreg,regrt,mem2reg,shift,aluimm,jal,s_ext;
 //datapath wires
 wire [WIDTH-1:0] p4,bpc,npc;
 wire [WIDTH-1:0] qa,qb,alua,alub,wd,r ;
 wire [WIDTH-1:0] sa ={27'b0,inst[10:6]};      //shift amount
 wire [15:0] s16={16{s_ext&inst[15]}};
 wire [WIDTH-1:0] i32={s16,imm};                //32 bit immediate
 wire [WIDTH-1:0] dis = {{16{inst[15]}}, imm, 2'b00}; //word distance
 wire [WIDTH-1:0] jpc = {p4[31:28],addr,2'b00}; //jump target
 wire [4:0] reg_dest ;   //rs or rt
 wire [4:0] wn =reg_dest|{5{jal}};
 wire z;

 control_unit m0 (op ,func,z, 
   mem2reg,pcsrc,wmem,aluc,shift,aluimm,wreg ,regrt,jal,s_ext);

  program_counter m1(npc,dis,
    clk,reset,
    pc_out,
   p4,bpc ) ;

   mux2_32 #(32) aluas (qa,sa,shift,alua);
   mux2_32 #(32) alubs (qb,i32,aluimm,alub);
   mux2_32 #(32) alu_m (aluout,datao,mem2reg,r);
   mux2_32 #(32)link (r,p4,jal,wd);

   mux2_5 reg_wn(rd,rt,regrt,reg_dest);
   mux4_32 #(32) nextpc(p4,bpc,qa,jpc,pcsrc,npc);

   regfile rf(rs,rt,wn,wd,wreg,clk,reset,qa,qb);
   alu unit(aluout,z,alua,alub,aluc);
 //
   assign datao =qb;
   
 endmodule
