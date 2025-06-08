`timescale 1ns / 1ps

module DDS_tb();
    reg clk;
    reg resetn;
    wire [15:0] Sine_out;
    
    DDS_Module uut1 (
    .clk(clk),
    .resetn(resetn),
    .Sine_out(Sine_out)
    );
    
    always #10 clk = ~clk;
    
    initial begin 
        clk = 1'b0;
        resetn = 1'b0;
        #200
        
        resetn = 1'b1;
        #1000
        
        $finish;
    end
endmodule
