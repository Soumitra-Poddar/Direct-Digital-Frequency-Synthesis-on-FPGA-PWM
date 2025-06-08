`timescale 1ns / 1ps

module PWM_Module(
    input  clk,
    input  resetn,
    input  [15:0] Sine_out,
    input  [15:0] Tri_out,
    output reg PWM    
    );
    
    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            PWM <= 1'b0;
        end
        else begin 
            PWM <= (Sine_out >= Tri_out) ? 1'b1 : 1'b0;
        end
    end
endmodule
