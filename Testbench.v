`timescale 1ns / 1ps

module Testbench();
    reg  clk;
    reg  resetn;
    wire [15:0] Sine_out, Tri_out;
    wire PWM;
        
    Top uut (
    .clk(clk),
    .resetn(resetn),
    .Sine_out(Sine_out),
    .Tri_out(Tri_out),
    .PWM(PWM)
    );
    
    always #10 clk = ~clk;
    
    initial begin 
        clk = 1'b0;
        resetn = 1'b0;
        end 
        initial
        #20 resetn = 1'b1;
    endmodule
