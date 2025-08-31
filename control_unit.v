module control_unit #(
    parameter WIDTH=32
 ) (
    op ,func,z, 
   mem2reg,pcsrc,wmem,aluc,shift,aluimm,wreg ,regrt,jal,s_ext
 );
 input [5:0] op,func;
 input z;
 output reg mem2reg,wmem,shift,aluimm,wreg,regrt,jal,s_ext ;
 output reg [3:0] aluc;
 output reg [1:0] pcsrc;
 always @(*) begin
   mem2reg=0;pcsrc=0;wmem=0;aluc=0;shift=0;aluimm=0;wreg=0;
   regrt=0; jal=0;s_ext=0;
   casex (op)
     6'b000000 :  case (func) //Rtype
                     6'b100000   : begin wreg=1; aluc=4'b0000; end //ADD
                     6'b100010   : begin wreg=1; aluc=4'b0100; end //SUB0
                     6'b100100   : begin wreg=1; aluc=4'b0001; end //AND
                     6'b100101   : begin wreg=1;
                                    aluc=4'b0101; 
                        
                     end  // OR
                     6'b100110   : begin
                        wreg=1;
                        aluc=4'b0010;
                     end //XOR
                     6'b000000   :begin
                        wreg=1;
                        shift=1;
                        aluc=4'b0011;
                     end //SLL
                     6'b000010   :begin
                        wreg=1;
                        shift=1;
                        aluc=4'b0111;
                     end //SRL
                     6'b000011   :begin
                        wreg=1;
                        shift=1;
                        aluc=4'b1111;
                     end//SRA
                     6'b001000   :begin
                        pcsrc=2'b10;
                     end //JR
                        default: begin aluc=4'b0000; end
                  endcase
                  //ADDI
     6'b001000 : begin 
                  wreg=1;
                  regrt=1;
                  aluimm=1;
                  s_ext=1;
                  aluc=4'b0000;
        
     end 
     6'b001100 : begin //ANDI
                  wreg=1;
                  regrt=1;
                  aluimm=1;
            
                  aluc=4'b0001;
              
     end    
     6'b001101 :begin //ORI
                   wreg=1;
                  regrt=1;
                  aluimm=1;
            
                  aluc=4'b0101;

     end
     6'b001110 :begin //XORI
                   wreg=1;
                  regrt=1;
                  aluimm=1;
            
                  aluc=4'b0010;
     end  
     6'b100011 :begin //ILW
                   wreg=1;
                  regrt=1;
                  mem2reg=1;
                  s_ext=1;
                  aluimm=1;
            
                  aluc=4'b0000;
     end
     6'b101011 :begin //ISW
                   
                  aluimm=1;
                  s_ext=1;
                  wmem=1;
            
                  aluc=4'b0000;
     end
     6'b000100 :begin //IBEQ
                   s_ext=1;
            
                  aluc=4'b0010;
                  if(z) pcsrc=2'b01;
     end
     6'b000101 :begin //IBNE
                   s_ext=1;
                   if(~z) pcsrc=2'b01;
            
                  aluc=4'b0100;
     end
     6'b001111 :begin //LUI
                   wreg=1;
                  regrt=1;
                  aluimm=1;
            
                  aluc=4'b0110;
     end
     6'b000010 :begin //IJ
                   pcsrc=2'b11;
     end   
     6'b000011 :begin //IJAL
                   wreg=1;
                  jal=1;
                  pcsrc=2'b11;
     end  



      
   endcase
   
 end


    
 endmodule
