`timescale 1ns / 1ps

module DDS_Top(
    input clk, reset,
    input [23:0] FCW,
    output wire signed [15:0] sine_out
    );
    
    wire slow_clk;
    wire [23:0] phase;
    wire [9:0]  rom_addr;
    
    Clk_Divider #(
        .clkdiv(500)
    )    uut1      (
        .clk_in(clk),
        .reset(reset),
        .clk(slow_clk)
    );
    
    Phase_Accumulator uut2 (
        .clk(slow_clk),
        .reset(reset),
        .FCW(FCW),
        .phase(phase)
    );
    
    assign rom_addr = phase[23:14];
    
    Phase_to_Amplitude uut3 (
        .clk(slow_clk),
        .amp_address(rom_addr),
        .amplitude(sine_out)
    );
    
endmodule