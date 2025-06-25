module pattern_gen #(
    parameter integer stim_size=8 ,
    parameter integer offset=5, cycles=8,period=10
) (
    output reg [stim_size-1:0] stim_pattern,
    input enable
);
    initial begin
        stim_pattern=8'h00;
        wait(enable==1);
        #(offset)
        for (integer i =0 ;i<cycles ;i++ ) begin
           for (integer j =0 ;j<(1<<stim_size) ;j++ ) begin
            #(period) stim_pattern=stim_pattern+1;
           end 
        end
    end

endmodule

//testbench for pattern generator
module t_pattern #(
    parameter stim_size=8,
    parameter integer offset=5,cycles=8,period=10 
) ();
wire [stim_size-1:0] stim_pattern;
reg enable;
 pattern_gen m1(stim_pattern,enable);
 initial begin
    enable =0;
    #15 enable =1;
 end
 initial begin
    $dumpfile("pattern.vcd");
    $dumpvars(0);
 end
    
endmodule
