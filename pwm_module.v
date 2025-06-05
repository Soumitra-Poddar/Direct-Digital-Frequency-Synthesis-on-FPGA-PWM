`timescale 1ns / 1ps

// PWM Module with Unipolar and Bipolar Support
// This module compares modulating signals with triangular carrier
// Supports both unipolar and bipolar PWM generation
module pwm_module (
    input wire clk,                    // System clock
    input wire reset,                  // Active high reset
    input wire signed [15:0] tri_wave, // Triangular carrier wave (-32768 to +32767)
    input wire signed [15:0] mod_signal, // Modulating signal (sine wave from DDS)
    input wire pwm_mode,               // PWM mode: 0=Unipolar, 1=Bipolar
    output reg pwm_out_unipolar,       // Unipolar PWM output (single output)
    output reg pwm_out_bipolar_p,      // Bipolar PWM positive output
    output reg pwm_out_bipolar_n       // Bipolar PWM negative output (complement)
);

    // Internal comparison results
    wire comparison_result;
    
    // Modulating signal scaling for better utilization
    // Scale the modulating signal to use full range of triangular wave
    wire signed [15:0] scaled_mod_signal;
    
    // For better PWM utilization, we might want to scale the modulating signal
    // Here we assume the modulating signal is already properly scaled
    assign scaled_mod_signal = mod_signal;
    
    // Main comparison: modulating signal vs triangular carrier
    // When mod_signal > tri_wave, comparison_result = 1
    // When mod_signal <= tri_wave, comparison_result = 0
    assign comparison_result = (scaled_mod_signal > tri_wave) ? 1'b1 : 1'b0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all PWM outputs
            pwm_out_unipolar <= 1'b0;
            pwm_out_bipolar_p <= 1'b0;
            pwm_out_bipolar_n <= 1'b0;
        end
        else begin
            // Generate PWM outputs based on mode
            if (pwm_mode == 1'b0) begin  // Unipolar Mode
                // In unipolar mode, we have single-ended output
                // PWM is HIGH when modulating signal > triangular carrier
                pwm_out_unipolar <= comparison_result;
                
                // Bipolar outputs are not used in unipolar mode
                pwm_out_bipolar_p <= 1'b0;
                pwm_out_bipolar_n <= 1'b0;
            end
            else begin  // Bipolar Mode
                // In bipolar mode, we have differential outputs
                // One output is the comparison result, other is its complement
                pwm_out_bipolar_p <= comparison_result;      // Positive output
                pwm_out_bipolar_n <= ~comparison_result;     // Negative output (inverted)
                
                // Unipolar output not used in bipolar mode
                pwm_out_unipolar <= 1'b0;
            end
        end
    end
    
endmodule
