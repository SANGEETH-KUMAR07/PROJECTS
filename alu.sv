module alu #(
    parameter WIDTH=32
) (
    output reg [WIDTH-1:0] sum,
    output   z  ,
    input [WIDTH-1:0] a,b,
    input [3:0] oper 
);
always@(*)
begin
    casex (oper)
        
        4'bx000:sum=a+b;                    //add
        4'bx100:sum=a+~b+1;                 //sub
        4'bx001:sum=a&b;                    //and
        4'bx101:sum=a|b;                    //or
        4'bx010:sum=a^b;                    //xor
        4'bx110:sum={b[15:0],16'h0000};     //lui load upper immidiate
        4'b0011:sum=b<<a[4:0];              //sll 
        4'b0111:sum=b>>a[4:0];              //slr
        4'b1111:sum=b>>>a[4:0];             //sra
        
        default:sum=a;
    endcase 
end
assign z=(sum==0);
endmodule 


// testbench //



module t_alu #(
    parameter WIDTH=32
) ();
reg[WIDTH-1:0] a,b;
reg[3:0]oper;

wire[WIDTH-1:0] sum;
wire z ;

alu m1 (sum,z,a,b,oper);

initial begin
    a=32'h00000072;
    b=32'h00000021;

    //oper=0;
    for (integer i =0 ;i<16 ;i++ ) begin
        #5 oper=i;
    end
end
initial begin
    $monitor("a=%h ,b=%h ,op=%b,sum=%h. ,z=%b",a,b,oper,sum,z);
    $dumpfile("alu.vcd");
    $dumpvars(0,t_alu);
end
    
endmodule
