`timescale 1ns / 1ps

module TriangularWave_Module(
    input  clk,
    input  resetn,
    output reg [15:0] Tri_out
);

    reg [15:0] counter;
    reg signed [15:0] tri_value;
    reg direction;
    
    parameter step_size = 16'd256;
    parameter MAX_VALUE = 16'd32767;
    parameter MIN_VALUE = -16'd32768;
    parameter STEP_INCREMENT = 16'd256;
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counter   <= 16'd0;
            tri_value <= MIN_VALUE;
            direction <= 1'b0;
            Tri_out   <= MIN_VALUE;
        end
        else begin            
            counter <= counter + 1'b1;
                        
            if (counter >= step_size) begin
                counter <= 16'd0;
                
                if (direction == 1'b0) begin
                    if (tri_value >= (MAX_VALUE - STEP_INCREMENT)) begin
                        tri_value <= MAX_VALUE;
                        direction <= 1'b1;
                    end
                    else begin
                        tri_value <= tri_value + STEP_INCREMENT;
                    end
                end
                else begin
                    if (tri_value <= (MIN_VALUE + STEP_INCREMENT)) begin
                        tri_value <= MIN_VALUE;
                        direction <= 1'b0;
                    end
                    else begin
                        tri_value <= tri_value - STEP_INCREMENT;
                    end
                end
                Tri_out <= tri_value;
            end
        end
    end
endmodule