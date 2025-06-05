`timescale 1ns / 1ps

module Clk_Divider #(
    parameter clkdiv = 500
    )(
    input clk_in, reset, 
    output reg clk
    );
     
    reg [$clog2(clkdiv)-1: 0] count = 0; 
     
    always @(posedge clk_in or posedge reset) begin     
        if (reset) begin 
            count <= 0; 
            clk   <= 0;
        end 
        else if (count == clkdiv/2 -1) begin 
            count <= 0;
            clk   <= ~clk;
        end 
        else begin 
            count  <= count + 1;
        end
    end 
endmodule
