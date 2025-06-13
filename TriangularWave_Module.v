`timescale 1ns / 1ps

module TriangularWave_Module (
    input  clk,
    input  resetn,
    output [15:0] Tri_out
);
    reg  [23:0] Accm;
    reg  [23:0] FCW;
    reg  [15:0] Tri_reg;
    wire [15:0] ramp_val;
    wire  direction;
    
    assign Tri_out   = Tri_reg;
    assign direction = Accm[23];
    assign ramp_val  = Accm[22:7];

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            Accm     <= 24'd0;
            FCW      <= 24'd16600; //d16384
            Tri_reg  <= 16'd0;
        end
        else begin
            Accm <= Accm + FCW;
            if (direction == 1'b0)
                Tri_reg <= ramp_val  - 16'd32768;
            else
                Tri_reg <= 16'd32767 - ramp_val;
        end
    end
endmodule