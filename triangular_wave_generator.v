`timescale 1ns / 1ps
// Triangular Wave Generator Module
// This module generates a triangular wave using counter logic
// Range: -32768 to +32767 (16-bit signed values)
module triangular_wave_generator (
    input wire clk,           // System clock
    input wire reset,         // Active high reset
    input wire [15:0] step_size, // Controls frequency of triangular wave
    output reg signed [15:0] tri_out  // 16-bit signed triangular wave output
);

    // Internal signals
    reg [15:0] counter;           // Internal counter for timing
    reg signed [15:0] tri_value;  // Current triangular wave value
    reg direction;                // Direction flag: 0=up, 1=down
    
    // Parameters for triangular wave limits
    parameter MAX_VALUE = 16'd32767;   // Maximum positive value
    parameter MIN_VALUE = -16'd32768;  // Maximum negative value (2's complement)
    parameter STEP_INCREMENT = 16'd256; // How much to increment per step
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all values to initial state
            counter <= 16'd0;
            tri_value <= MIN_VALUE;  // Start from minimum value
            direction <= 1'b0;       // Start counting up
            tri_out <= MIN_VALUE;
        end
        else begin
            // Increment counter every clock cycle
            counter <= counter + 1'b1;
            
            // Check if it's time to update triangular wave
            // step_size controls the frequency - larger values = slower triangle
            if (counter >= step_size) begin
                counter <= 16'd0;  // Reset counter
                
                // Update triangular wave based on direction
                if (direction == 1'b0) begin  // Counting up
                    if (tri_value >= (MAX_VALUE - STEP_INCREMENT)) begin
                        // Reached maximum, start counting down
                        tri_value <= MAX_VALUE;
                        direction <= 1'b1;  // Switch to down direction
                    end
                    else begin
                        // Continue counting up
                        tri_value <= tri_value + STEP_INCREMENT;
                    end
                end
                else begin  // Counting down (direction == 1'b1)
                    if (tri_value <= (MIN_VALUE + STEP_INCREMENT)) begin
                        // Reached minimum, start counting up
                        tri_value <= MIN_VALUE;
                        direction <= 1'b0;  // Switch to up direction
                    end
                    else begin
                        // Continue counting down
                        tri_value <= tri_value - STEP_INCREMENT;
                    end
                end
                
                // Update output
                tri_out <= tri_value;
            end
        end
    end

endmodule