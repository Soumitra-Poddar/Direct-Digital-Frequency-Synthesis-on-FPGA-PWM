`timescale 1ns / 1ps

module Phase_Accumulator(
    input clk, reset, 
    input [23:0] FCW,            // Frequency Control Word
    output reg [23:0] phase      // Phase output 
    );
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            phase <= 24'b0;
        end
        else begin
            phase <= phase + FCW; // Accumulates phase and wraps around automatically
        end    
    end
endmodule
