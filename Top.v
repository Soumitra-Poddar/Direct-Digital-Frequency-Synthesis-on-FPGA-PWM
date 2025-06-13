`timescale 1ns / 1ps

module Top(
    input  clk, 
    input  resetn,
    output [15:0] Sine_out, Tri_out,
    output PWM
    );
    
//    wire [15:0] Sine_out, Tri_out;
    
    DDS_Module inst1 (
    .clk(clk),
    .resetn(resetn),
    .Sine_out(Sine_out)
    );
    
    TriangularWave_Module inst2 (
    .clk(clk),
    .resetn(resetn),
    .Tri_out(Tri_out)
    );
    
    PWM_Module inst3 (
    .clk(clk),
    .resetn(resetn),
    .Sine_out(Sine_out),
    .Tri_out(Tri_out),
    .PWM(PWM)
    );
    
endmodule