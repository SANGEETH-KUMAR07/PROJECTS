/* Instruction set for the RISC_SPM machine.

           Instruction Word
 Instr   opcode     Src      dest        Action

 NOP      0000      ??       ??          none
 ADD      0001      SrC      dest        dest < = src + dest
 SUB      0010      SrC      dest        dest <= dest - src
 AND      0011      SrC      dest        dest < = src && dest
 NOT      0100      SrC      dest        dest <= ~ src
 RD*      0101      ??       dest        d e s t < = m e m o r y [A d d _ R]
 WR*      0110      SrC      ??          memory[Add_R] < = src
 BR*      0111      ??       ??          PC <= memory[ Add_R]
 BRZ*     1000      ??       ??          PC <= memory [Add_R]
 HALT     1111      ??       ??          Halts execution until reset 

 *Requires a second word of data;  
 ? denotes a don't-care.*/
 `timescale 1ns/1ps
 
module RISC_SPM #(
   parameter wordsize=8,sel1_bus=3,sel2_bus=2
 ) (
   clk,rst 
 );
 wire[sel1_bus-1:0] sel_bus1_mux;
 wire[sel2_bus-1:0] sel_bus2_mux;
 input clk,rst;

 wire zero;
 wire[wordsize-1:0] instruction,address,Bus_1,mem_word; 

 wire load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,load_IR;
 wire load_add_reg,load_reg_Y,load_reg_Z,write;

 processing_unit m0 ( instruction,zero,address,Bus_1,
      mem_word,load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,
      sel_bus1_mux,load_IR,load_add_reg,load_reg_Y,load_reg_Z,sel_bus2_mux,
      clk,rst
    );
 control_unit m1   (
   load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,sel_bus1_mux,
   load_IR,load_add_reg,load_reg_Y,load_reg_Z,sel_bus2_mux,write,
   instruction,zero ,
   clk,rst 
 );
 memory_unit M2_SRAM (
   .data_out(mem_word),.data_in(Bus_1),.address(address),.clk(clk),.write(write) 
 );

   
 endmodule
 
module processing_unit #(
    parameter wordsize=8,op_code=4,sel1_bus=3,sel2_bus=2
  ) ( instruction,zero,address,Bus_1,
      mem_word,load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,
      sel_bus1_mux,load_IR,load_add_reg,load_reg_Y,load_reg_Z,sel_bus2_mux,
      clk,rst
    );

  output [wordsize-1:0] instruction,address,Bus_1   ;
  output zero;
  input [wordsize-1:0] mem_word;
  input load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC;
  input [sel1_bus-1:0] sel_bus1_mux;
  input [sel2_bus-1:0] sel_bus2_mux;
  input load_IR,load_add_reg,load_reg_Y,load_reg_Z;
  input clk,rst;

  wire  load_R0,load_R1,load_R2,load_R3;
  wire[wordsize-1:0] bus_2;
  wire[wordsize-1:0] R0_out,R1_out,R2_out,R3_out;
  wire[wordsize-1:0] PC_count,Y_value,alu_out;
  wire alu_zero_flag;
  wire[op_code-1:0] opcode=instruction[wordsize-1:wordsize-op_code];

  register_unit R0    (.data_out(R0_out),.data_in(bus_2),.load(load_R0),.clk(clk),.rst(rst));
  register_unit R1    (.data_out(R1_out),.data_in(bus_2),.load(load_R1),.clk(clk),.rst(rst));
  register_unit R2    (.data_out(R2_out),.data_in(bus_2),.load(load_R2),.clk(clk),.rst(rst));
  register_unit R3    (.data_out(R3_out),.data_in(bus_2),.load(load_R3),.clk(clk),.rst(rst));
  register_unit Reg_Y (.data_out(Y_value),.data_in(bus_2),.load(load_reg_Y),.clk(clk),.rst(rst));
  dflop         Reg_Z (.data_out(zero),.data_in(alu_zero_flag),.load(load_reg_Z),.clk(clk),.rst(rst));
  register_unit Address_Register (.data_out(address),.data_in(bus_2),.load(load_add_reg),.clk(clk),.rst(rst));
  register_unit Instruction_Register (.data_out(instruction),.data_in(bus_2),.load(load_IR),.clk(clk),.rst(rst));
  program_counter PC  (.count(PC_count),.data_in(bus_2),.load_PC(load_PC),.inc_PC(inc_PC),.clk(clk),.rst(rst));
  multiplexor_5ch mux1 (.mux_out(Bus_1),.data_a(R0_out),.data_b(R1_out),.data_c(R2_out),.data_d(R3_out),.data_e(PC_count),.sel(sel_bus1_mux) );
  multiplexor_3ch mux2 (.mux_out(bus_2),.data_a(alu_out),.data_b(Bus_1),.data_c(mem_word),.sel(sel_bus2_mux) );
  alu_risc alu (.alu_zero_flag(alu_zero_flag),.alu_out(alu_out),.data_1(Y_value),.data_2(Bus_1),.sel(opcode));
  
 endmodule

 module register_unit #(
    parameter wordsize=8
 ) (
    data_out,
    data_in,load,
    clk,rst
 );
 output reg [wordsize-1:0] data_out;
 input [wordsize-1:0] data_in;
 input load,clk,rst;

 always @(posedge clk,negedge rst) begin
    if(rst==0) data_out<=0;
    else if(load) data_out<=data_in;
 end
    
 endmodule

 module dflop(
    data_out,data_in,load,clk,rst
 );
  output reg data_out;
  input data_in,load,clk,rst;
  always @(posedge clk,negedge rst) begin
     if(rst==0) data_out<=0;
     else if(load) data_out<=data_in;
  end
    
 endmodule

 module program_counter #(
    parameter wordsize=8
 ) (
    count,data_in,load_PC,inc_PC,clk,rst
 );
 output reg[wordsize-1:0] count;
 input [wordsize-1:0] data_in;
 input load_PC,inc_PC,clk,rst;
 always @(posedge clk,negedge rst) begin
    if(rst==0) count<=0;
    else if(load_PC) count<=data_in;
    else if(inc_PC)  count<=count+1;
 end
    
 endmodule

 module multiplexor_5ch #(
    parameter wordsize=8
 ) (
    mux_out,
    data_a,data_b,data_c,data_d,data_e,
    sel 
 );
 output [wordsize-1:0] mux_out;
 input [wordsize-1:0] data_a,data_b,data_c,data_d,data_e;
 input [2:0] sel;
 assign mux_out= (sel==0) ?data_a:(sel==1)
                          ?data_b:(sel==2)
                          ?data_c:(sel==3)
                          ?data_d:(sel==4)
                          ?data_e:{wordsize{ 1'bx }};
    
 endmodule

 module multiplexor_3ch #(
    parameter wordsize=8
 ) (
    mux_out,
    data_a,data_b,data_c,
    sel 
 );
 output [wordsize-1:0] mux_out;
 input [wordsize-1:0] data_a,data_b,data_c;
 input [1:0] sel;
 assign mux_out= (sel==0) ?data_a:(sel==1)
                          ?data_b:(sel==2)
                          ?data_c:{wordsize{ 1'bx }};
                          
    
 endmodule

 module alu_risc #(
    parameter wordsize=8,op_code=4,
    parameter NOP =4'b0000,
    parameter ADD =4'b0001,
    parameter SUB =4'b0010,
    parameter AND =4'b0011,
    parameter NOT =4'b0100,
    parameter RD  =4'b0101,
    parameter WR  =4'b0110,
    parameter BR  =4'b0111,
    parameter BRZ =4'b1000
 ) (
    alu_zero_flag,alu_out,data_1,data_2,sel
 );
 output reg[wordsize-1:0]alu_out;
 output alu_zero_flag;
 input[wordsize-1:0] data_1,data_2;
 input[op_code-1:0] sel;

 assign alu_zero_flag=~|alu_out;
 always @(sel,data_1,data_2) begin
    case (sel)
        NOP: alu_out=0;
        ADD: alu_out=data_1+data_2;
        SUB: alu_out=data_2-data_1;
        AND: alu_out=data_1&data_2;
        NOT: alu_out=~data_2; 
        default: alu_out=0;
    endcase
 end
 endmodule

 
/*S_idle    State entered after reset is asserted. No action.

  S_fet1    Load the address register with the contents of the program
            counter. (Note: PC is initialized to the starting address by the reset
            action.) The state is entered at the first active clock after reset is
            de-asserted, and is revisited after a NOP instruction is decoded.

  S_fet2    Load the instruction register with the word addressed by the
            address register, and increment the program counter to point to the
            next location in memory, in anticipation of the next instruction or
            data fetch.

  S_dec    Decode the instruction register and assert signals to control
            datapaths and register transfers.


  S_ex1     Execute the ALU operation for a single-byte instruction,
            conditionally assert the zero flag, and load the destination register.

  S_rd1     Load the address register with the second byte of a RD
            instruction, and increment the PC.

  S_rd2     Load the destination register with the memory word addressed by
            the byte loaded in S_rd1.

  S_wr1     Load the address register with the second byte of a WR instruction,
            and increment the PC.

  S_wr2     Load the destination register with the memory word addressed by
            the byte loaded in S_wrl.

  S_brl     Load the address register with the second byte of a BR instruction,
            and increment the PC.

  S_br2     Load the program counter with the memory word addressed by the
            byte loaded in S_brl.

  S_halt    Default state to trap failure to decode a valid instruction.*/
  
module control_unit(
   load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC,sel_bus1_mux,
   load_IR,load_add_reg,load_reg_Y,load_reg_Z,sel_bus2_mux,write,
   instruction,zero ,
   clk,rst 
 );
 parameter wordsize=8 ,sel1_bus=3, sel2_bus=2 ;
 parameter state_size=4,op_code=4,src_size=2,dest_size=2;
 //state codes
 parameter S_idle=0,S_fet1=1,S_fet2=2,S_dec=3;
 parameter S_ex1=4,S_rd1=5,S_rd2=6,S_wr1=7,S_wr2=8,S_br1=9,S_br2=10,S_halt=11;

 //opcodes
 parameter NOP=0,ADD=1,SUB=2,AND=3,NOT=4,RD=5,WR=6,BR=7,BRZ=8;

 //sources and destination codes
 parameter R0=0,R1=1,R2=2,R3=3;

 output reg load_R0,load_R1,load_R2,load_R3,load_PC,inc_PC;
 output[sel1_bus-1:0] sel_bus1_mux;
 output[sel2_bus-1:0] sel_bus2_mux;
 output reg  load_IR,load_add_reg,load_reg_Y,load_reg_Z,write;
 input [wordsize-1:0] instruction;
 input zero,clk,rst;

 reg[state_size-1:0] state,next_state;
 reg Sel_ALU,Sel_bus1,Sel_Mem;
 reg Sel_R0,Sel_R1,Sel_R2,Sel_R3,Sel_PC,err_flag;

 wire [op_code-1:0]opcode=instruction[wordsize-1:wordsize-op_code];
 wire [src_size-1:0]src=instruction[src_size+dest_size-1:dest_size];
 wire [dest_size-1:0]dest=instruction[dest_size-1:0];

 assign sel_bus1_mux[sel1_bus-1:0]=Sel_R0?0:
                                   Sel_R1?1:
                                   Sel_R2?2:
                                   Sel_R3?3:
                                   Sel_PC?4:3'bx;

 assign sel_bus2_mux[sel2_bus-1:0]=Sel_ALU?0:
                                    Sel_bus1?1:
                                    Sel_Mem?2:2'bx;

 always @(posedge clk,negedge rst) begin:state_transitions
    if(rst==0) state<=S_idle;
    else state<=next_state;
 end :state_transitions

 always @(state,opcode,src,dest,zero) begin:output_and_nextstate
   Sel_R0=0;   Sel_R1=0;  Sel_R2=0;  Sel_R3=0;   Sel_PC=0;
   load_R0=0;  load_R1=0;  load_R2=0;  load_R3=0; load_PC=0;

   load_IR=0;  load_add_reg=0;  load_reg_Y=0;  load_reg_Z=0;
   inc_PC=0;   Sel_bus1=0;      Sel_ALU=0;     Sel_Mem=0;
   write=0;    err_flag=0;      next_state=state;

   case (state)
      S_idle:  next_state=S_fet1;

      S_fet1:  begin
                  next_state=S_fet2;
                  Sel_PC=1;
                  Sel_bus1=1;
                  load_add_reg=1;
      end   //S_fet1

      S_fet2:   begin
                  next_state=S_dec;
                  Sel_Mem=1;
                  load_IR=1;
                  inc_PC=1;
      end //S_fet2

      S_dec:     begin
                 case (opcode)
                  NOP: next_state=S_fet1;
                  ADD,SUB,AND:begin
                     Sel_bus1=1;
                     load_reg_Y=1;
                     next_state=S_ex1;
                     case (src)
                         R0: Sel_R0=1; 
                         R1: Sel_R1=1; 
                         R2: Sel_R2=1; 
                         R3: Sel_R3=1; 
                         default: err_flag=1;
                     endcase
                  end        //ADD ,SUB,AND 
                  NOT:begin
                      Sel_bus1=1;
                      Sel_ALU=1;
                      load_reg_Z=1;
                      next_state=S_fet1;
                      case (src)
                         R0: Sel_R0=1; 
                         R1: Sel_R1=1; 
                         R2: Sel_R2=1; 
                         R3: Sel_R3=1; 
                         default: err_flag=1;
                      endcase
                      case (dest)
                         R0: load_R0=1; 
                         R1: load_R1=1; 
                         R2: load_R2=1; 
                         R3: load_R3=1; 
                         default: err_flag=1;
                      endcase
                  end //NOT
                  RD: begin
                     Sel_PC=1;
                     Sel_bus1=1;
                     load_add_reg=1;
                     next_state=S_rd1; 
                  end //RD
                  WR:begin
                     Sel_PC=1;
                     Sel_bus1=1;
                     load_add_reg=1;
                     next_state=S_wr1;
                  end//WR
                  BR:begin
                     Sel_PC=1;
                     Sel_bus1=1;
                     load_add_reg=1;
                     next_state=S_br1;
                  end//BR
                  BRZ:begin
                     if(zero)begin
                     Sel_PC=1;
                     Sel_bus1=1;
                     load_add_reg=1;
                     next_state=S_br1;
                     end
                     else begin
                        inc_PC=1;
                        next_state=S_fet1;
                     end
                  end
                  default: next_state=S_halt;
                 endcase
      end//S_dec

      S_ex1:begin
            Sel_ALU=1;
            load_reg_Z=1;
            next_state=S_fet1;
            case (dest)
                  R0: begin load_R0=1; Sel_R0=1;end
                  R1: begin load_R1=1; Sel_R1=1;end
                  R2: begin load_R2=1; Sel_R2=1;end
                  R3: begin load_R3=1; Sel_R3=1;end
                  default: err_flag=1;
            endcase
      end //S_ex1

      S_rd1: begin
             Sel_Mem=1;
             load_add_reg=1;
             inc_PC=1;
             next_state=S_rd2;
      end//S_rd1

      S_rd2:begin
            Sel_Mem=1;
            next_state=S_fet1;
            case (dest)
                  R0: load_R0=1; 
                  R1: load_R1=1; 
                  R2: load_R2=1; 
                  R3: load_R3=1; 
                  default: err_flag=1;
            endcase
      end//S_rd2

      S_wr1:begin
            Sel_Mem=1;
            load_add_reg=1;
            inc_PC=1;
            next_state=S_wr2;
      end //S_wr1

      S_wr2:begin
           write=1;
           next_state=S_fet1;
         case (src)
            R0: Sel_R0=1; 
            R1: Sel_R1=1; 
            R2: Sel_R2=1; 
            R3: Sel_R3=1; 
            default: err_flag=1;
         endcase
      end //S_wr2

      S_br1: begin
             Sel_Mem=1;
             load_add_reg=1;
             next_state=S_br2;
      end //S_br1

      S_br2: begin
            Sel_Mem=1;
            load_PC=1;
            next_state=S_fet1;
      end //S_br2

      S_halt:next_state=S_halt;

      default: next_state=S_idle;
   endcase  
 end :output_and_nextstate                                                               

 endmodule  


module memory_unit #(
   parameter wordsize=8, memory_size=256
 ) (
   data_out,data_in,address,clk,write 
 );
 output[wordsize-1:0] data_out;
 input[wordsize-1:0] data_in,address;
 input clk,write;
 reg[wordsize-1:0] memory[memory_size-1:0];
 assign data_out=memory[address];
 always @(posedge clk ) begin
   if(write) memory[address]<=data_in;
 end
 endmodule 

/*module test_RISC_SPM ();
 reg rst;
 reg clk;
 parameter word_size = 8;
 reg [8: 0] k;
 
 RISC_SPM M2 (clk, rst);
 // define probes
 wire [word_size-1: 0] word0, word1, word2, word3, word4, word5, word6;
 wire [word_size-1: 0] word7, word8, word9, word10, word11, word12, word13;
 wire [word_size-1: 0] word14;
 wire [word_size-1: 0] word128, word129, word130, word131, word132, word255;
 wire [word_size-1: 0] word133, word134, word135, word136, word137;
 wire [word_size-1: 0] word138, word139, word140;
 assign word0 = M2.M2_SRAM.memory[0];
 assign word1 = M2.M2_SRAM.memory[1];
 assign word2 = M2.M2_SRAM.memory[2];
 assign word3 = M2.M2_SRAM.memory[3];
 assign word4 = M2.M2_SRAM.memory[4];
 assign word5 = M2.M2_SRAM.memory[5];
 assign word6 = M2.M2_SRAM.memory[6];
 assign word7 = M2.M2_SRAM.memory[7];
 assign word8 = M2.M2_SRAM.memory[8];
 assign word9 = M2.M2_SRAM.memory[9];
 assign word10 = M2.M2_SRAM.memory[10];
 assign word11 = M2.M2_SRAM.memory[11];
 assign word12 = M2.M2_SRAM.memory[121];
 assign word13 = M2.M2_SRAM.memory[13];
 assign word14 = M2.M2_SRAM.memory[14];
 assign word128 = M2.M2_SRAM.memory[128];
 assign word129 = M2.M2_SRAM.memory[129];
 assign word130 = M2.M2_SRAM.memory[130];
 assign word131 = M2.M2_SRAM.memory[131];
 assign word132 = M2.M2_SRAM.memory[132];
 assign word133 = M2.M2_SRAM.memory[133];
 assign word134 = M2.M2_SRAM.memory[134];
 assign word135 = M2.M2_SRAM.memory[135];
 assign word136 = M2.M2_SRAM.memory[136];
 assign word137 = M2.M2_SRAM.memory[137];
 assign word138 = M2.M2_SRAM.memory[138];
 assign word139 = M2.M2_SRAM.memory[139];
 assign word140 = M2.M2_SRAM.memory[140];
 assign word255 = M2.M2_SRAM.memory[255];
 initial #2800 $finish;
 
 //Flush Memory
 initial begin: Flush_Memory
 #2 rst = 0; for (k=0; k<=255; k=k+1)M2.M2_SRAM.memory[k] = 0; #10 rst = 1;
 end
 
 initial begin: Load_program
 #5 ;
 //                      opcode_src_dest
 M2.M2_SRAM.memory[0] = 8'b00000000;
 M2.M2_SRAM.memory[1] = 8'b01010010;
 M2.M2_SRAM.memory[2] = 130;
 
 M2.M2_SRAM.memory [3] = 8'b01010011;
 M2.M2_SRAM.memory[4] = 131;
 M2.M2_SRAM.memory[5] = 8'b01010001;
 M2.M2_SRAM.memory[6] = 128;
 M2.M2_SRAM.memory [7] = 8'b01010000;
 M2.M2_SRAM.memory[8] = 129;
 M2.M2_SRAM.memory[9] = 8'b00100001;
 M2.M2_SRAM.memory[10] = 8'b10000000;
 M2.M2_SRAM.memory[11] = 134;
 M2.M2_SRAM.memory[12] = 8'b00011011;
 M2.M2_SRAM.memory[13] = 8'b01110011;
 M2.M2_SRAM.memory[14] = 140;
 // Load data
 M2.M2_SRAM.memory [128] = 6;
 M2.M2_SRAM.memory[129] = 1;
 M2.M2_SRAM.memory[130] = 2;
 M2.M2_SRAM.memory[131] = 0;
 M2.M2_SRAM.memory[134] = 139;
 //M2.M2_SRAM.memory[135] = 0;
 M2.M2_SRAM.memory[139] = 8'b11110000;
 M2.M2_SRAM.memory[140] = 9;
 end
 initial begin
   clk=0;
   forever #5 clk=~clk;
 end

 initial begin
   $dumpfile("risc.vcd");
   $dumpvars(2,test_RISC_SPM);
 end

 endmodule */

 module testbench_all_cases();
    reg clk, rst;
    parameter wordsize = 8;
    integer i;

    RISC_SPM uut (clk, rst);

    // Monitor registers
    wire [wordsize-1:0] R0 = uut.m0.R0_out;
    wire [wordsize-1:0] R1 = uut.m0.R1_out;
    wire [wordsize-1:0] R2 = uut.m0.R2_out;
    wire [wordsize-1:0] R3 = uut.m0.R3_out;

    // Monitor memory
    wire [wordsize-1:0] mem128 = uut.M2_SRAM.memory[128];
    wire [wordsize-1:0] mem129 = uut.M2_SRAM.memory[129];
    wire [wordsize-1:0] mem130 = uut.M2_SRAM.memory[130];
    wire [wordsize-1:0] mem131 = uut.M2_SRAM.memory[131];
    wire [wordsize-1:0] mem140 = uut.M2_SRAM.memory[140];

    initial begin
        $dumpfile("risc.vcd");
        $dumpvars(0, testbench_all_cases);
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Program & data load
    initial begin
        rst = 0;
        #2;
        // Clear memory
        for (i = 0; i < 256; i = i + 1) uut.M2_SRAM.memory[i] = 0;
        #10 rst = 1;

        // Test Program - covers all instructions
        // Addr : Instruction (Binary) -- Comment

        uut.M2_SRAM.memory[0]  = 8'b00000000;       // NOP

        uut.M2_SRAM.memory[1]  = 8'b01010000;       // RD R0
        uut.M2_SRAM.memory[2]  = 8'd128;

        uut.M2_SRAM.memory[3]  = 8'b01010001;       // RD R1
        uut.M2_SRAM.memory[4]  = 8'd129;

        uut.M2_SRAM.memory[5]  = 8'b01010010;       // RD R2
        uut.M2_SRAM.memory[6]  = 8'd130;

        uut.M2_SRAM.memory[7]  = 8'b00010001;       // ADD R0 -> R1 (R1 = R1 + R0)

        uut.M2_SRAM.memory[8]  = 8'b00100001;       // SUB R0 -> R1 (R1 = R1 - R0)

        uut.M2_SRAM.memory[9]  = 8'b00110001;       // AND R0 -> R1 (R1 = R1 & R0)

        uut.M2_SRAM.memory[10] = 8'b01000001;       // NOT R0 -> R1 (R1 = ~R0)

        uut.M2_SRAM.memory[11] = 8'b01100001;       // WR R0 to mem[140]
        uut.M2_SRAM.memory[12] = 8'd140;

        uut.M2_SRAM.memory[13] = 8'b01010011;       // RD R3
        uut.M2_SRAM.memory[14] = 8'd131;

        uut.M2_SRAM.memory[15] = 8'b01110000;       // BR to address stored in [132]
        uut.M2_SRAM.memory[16] = 8'd132;

        uut.M2_SRAM.memory[17] = 8'b10000000;       // BRZ to address stored in [133] (should not branch)
        uut.M2_SRAM.memory[18] = 8'd133;

        uut.M2_SRAM.memory[19] = 8'b11110000;       // HALT

        // Destination for branch (set from mem[132] and mem[133])
        uut.M2_SRAM.memory[132] = 8'd19;  // Target of BR
        uut.M2_SRAM.memory[133] = 8'd19;  // Target of BRZ
        uut.M2_SRAM.memory[128] = 8'd15;  // For RD R0
        uut.M2_SRAM.memory[129] = 8'd5;   // For RD R1
        uut.M2_SRAM.memory[130] = 8'd1;   // For RD R2
        uut.M2_SRAM.memory[131] = 8'd255; // For RD R3 (test value)
    end

    // End simulation on HALT
    initial begin
   #1500; // Enough time to run all instructions
        $display("\nFinal Register Values:");
        $display("R0: %d", R0);
        $display("R1: %d", R1);
        $display("R2: %d", R2);
        $display("R3: %d", R3);
        $display("mem[140]: %d", mem140);
        $display("Simulation complete.");
        $finish;
    end
endmodule
