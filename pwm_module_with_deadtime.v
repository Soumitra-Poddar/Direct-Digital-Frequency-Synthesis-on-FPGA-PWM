`timescale 1ns / 1ps
// PWM Module with Dead-Time Logic Implementation
// Prevents shoot-through current in H-bridge applications
// Dead-time ensures both outputs are never HIGH simultaneously
module pwm_module_with_deadtime (
    input wire clk,                    // System clock
    input wire reset,                  // Active high reset
    input wire signed [15:0] tri_wave, // Triangular carrier wave
    input wire signed [15:0] mod_signal, // Modulating signal (sine wave)
    input wire pwm_mode,               // PWM mode: 0=Unipolar, 1=Bipolar
    input wire [7:0] dead_time_cycles, // Dead-time in clock cycles (0-255)
    output reg pwm_out_unipolar,       // Unipolar PWM output
    output reg pwm_out_bipolar_p,      // Bipolar PWM positive output (with dead-time)
    output reg pwm_out_bipolar_n       // Bipolar PWM negative output (with dead-time)
);

    // Raw comparison result (before dead-time processing)
    wire comparison_result;
    reg comparison_result_reg;         // Registered version for edge detection
    reg comparison_prev;               // Previous comparison result
    
    // Dead-time state machine states
    localparam IDLE = 2'b00;           // Normal operation
    localparam DEAD_TIME_P_TO_N = 2'b01; // Dead-time when switching from P to N
    localparam DEAD_TIME_N_TO_P = 2'b10; // Dead-time when switching from N to P
    
    // Dead-time control signals
    reg [1:0] dead_time_state;         // Current state of dead-time FSM
    reg [7:0] dead_time_counter;       // Counter for dead-time duration
    reg dead_time_active;              // Flag indicating dead-time is active
    
    // Edge detection signals
    wire pos_edge;                     // Rising edge of comparison result
    wire neg_edge;                     // Falling edge of comparison result
    
    // Main comparison logic
    assign comparison_result = (mod_signal > tri_wave) ? 1'b1 : 1'b0;
    
    // Edge detection: detect transitions in comparison result
    assign pos_edge = comparison_result & ~comparison_prev;  // 0->1 transition
    assign neg_edge = ~comparison_result & comparison_prev;  // 1->0 transition
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all signals
            comparison_result_reg <= 1'b0;
            comparison_prev <= 1'b0;
            dead_time_state <= IDLE;
            dead_time_counter <= 8'd0;
            dead_time_active <= 1'b0;
            pwm_out_unipolar <= 1'b0;
            pwm_out_bipolar_p <= 1'b0;
            pwm_out_bipolar_n <= 1'b0;
        end
        else begin
            // Register comparison result and create previous value for edge detection
            comparison_result_reg <= comparison_result;
            comparison_prev <= comparison_result_reg;
            
            if (pwm_mode == 1'b0) begin  
                // =============== UNIPOLAR MODE ===============
                // No dead-time needed in unipolar mode
                pwm_out_unipolar <= comparison_result;
                pwm_out_bipolar_p <= 1'b0;
                pwm_out_bipolar_n <= 1'b0;
                dead_time_state <= IDLE;
                dead_time_active <= 1'b0;
            end
            else begin  
                // =============== BIPOLAR MODE WITH DEAD-TIME ===============
                pwm_out_unipolar <= 1'b0;  // Not used in bipolar mode
                
                // Dead-time state machine
                case (dead_time_state)
                    IDLE: begin
                        // Normal operation - check for transitions
                        dead_time_active <= 1'b0;
                        
                        if (dead_time_cycles > 0) begin  // Only apply dead-time if configured
                            if (pos_edge) begin
                                // Transition from 0->1: Need dead-time before turning ON positive output
                                // Turn OFF negative output immediately, start dead-time
                                pwm_out_bipolar_n <= 1'b0;
                                pwm_out_bipolar_p <= 1'b0;  // Keep positive OFF during dead-time
                                dead_time_counter <= dead_time_cycles;
                                dead_time_state <= DEAD_TIME_N_TO_P;
                                dead_time_active <= 1'b1;
                            end
                            else if (neg_edge) begin
                                // Transition from 1->0: Need dead-time before turning ON negative output
                                // Turn OFF positive output immediately, start dead-time
                                pwm_out_bipolar_p <= 1'b0;
                                pwm_out_bipolar_n <= 1'b0;  // Keep negative OFF during dead-time
                                dead_time_counter <= dead_time_cycles;
                                dead_time_state <= DEAD_TIME_P_TO_N;
                                dead_time_active <= 1'b1;
                            end
                            else begin
                                // No transition - maintain current state (without dead-time)
                                if (!dead_time_active) begin
                                    pwm_out_bipolar_p <= comparison_result_reg;
                                    pwm_out_bipolar_n <= ~comparison_result_reg;
                                end
                            end
                        end
                        else begin
                            // No dead-time configured - direct output
                            pwm_out_bipolar_p <= comparison_result_reg;
                            pwm_out_bipolar_n <= ~comparison_result_reg;
                        end
                    end
                    
                    DEAD_TIME_N_TO_P: begin
                        // Dead-time period: transitioning from N-active to P-active
                        // Both outputs remain OFF during this period
                        dead_time_active <= 1'b1;
                        pwm_out_bipolar_p <= 1'b0;
                        pwm_out_bipolar_n <= 1'b0;
                        
                        if (dead_time_counter > 0) begin
                            dead_time_counter <= dead_time_counter - 1'b1;
                        end
                        else begin
                            // Dead-time expired - turn ON positive output
                            pwm_out_bipolar_p <= 1'b1;
                            pwm_out_bipolar_n <= 1'b0;
                            dead_time_state <= IDLE;
                            dead_time_active <= 1'b0;
                        end
                    end
                    
                    DEAD_TIME_P_TO_N: begin
                        // Dead-time period: transitioning from P-active to N-active
                        // Both outputs remain OFF during this period
                        dead_time_active <= 1'b1;
                        pwm_out_bipolar_p <= 1'b0;
                        pwm_out_bipolar_n <= 1'b0;
                        
                        if (dead_time_counter > 0) begin
                            dead_time_counter <= dead_time_counter - 1'b1;
                        end
                        else begin
                            // Dead-time expired - turn ON negative output
                            pwm_out_bipolar_p <= 1'b0;
                            pwm_out_bipolar_n <= 1'b1;
                            dead_time_state <= IDLE;
                            dead_time_active <= 1'b0;
                        end
                    end
                    
                    default: begin
                        // Safety: return to IDLE state
                        dead_time_state <= IDLE;
                        dead_time_active <= 1'b0;
                        pwm_out_bipolar_p <= 1'b0;
                        pwm_out_bipolar_n <= 1'b0;
                    end
                endcase
            end
        end
    end
    
    // Optional: Output status signals for debugging
    // These can be removed in final implementation
    reg [7:0] debug_dead_time_remaining;
    reg debug_transition_detected;
    
    always @(posedge clk) begin
        debug_dead_time_remaining <= dead_time_counter;
        debug_transition_detected <= pos_edge | neg_edge;
    end

endmodule

// Alternative simpler dead-time implementation
// Use this if you prefer a more straightforward approach
module pwm_simple_deadtime (
    input wire clk,
    input wire reset,
    input wire signed [15:0] tri_wave,
    input wire signed [15:0] mod_signal,
    input wire [7:0] dead_time_cycles,
    output reg pwm_out_p,
    output reg pwm_out_n
);

    wire comparison;
    reg comparison_prev;
    reg [7:0] dead_counter_p, dead_counter_n;
    
    assign comparison = (mod_signal > tri_wave);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            comparison_prev <= 1'b0;
            dead_counter_p <= 8'd0;
            dead_counter_n <= 8'd0;
            pwm_out_p <= 1'b0;
            pwm_out_n <= 1'b0;
        end
        else begin
            comparison_prev <= comparison;
            
            // Handle positive output with dead-time
            if (comparison && !comparison_prev) begin
                // Rising edge: start dead-time for positive output
                dead_counter_p <= dead_time_cycles;
                pwm_out_n <= 1'b0;  // Turn off negative immediately
            end
            else if (dead_counter_p > 0) begin
                dead_counter_p <= dead_counter_p - 1'b1;
                pwm_out_p <= 1'b0;  // Keep positive off during dead-time
            end
            else begin
                pwm_out_p <= comparison;
            end
            
            // Handle negative output with dead-time
            if (!comparison && comparison_prev) begin
                // Falling edge: start dead-time for negative output
                dead_counter_n <= dead_time_cycles;
                pwm_out_p <= 1'b0;  // Turn off positive immediately
            end
            else if (dead_counter_n > 0) begin
                dead_counter_n <= dead_counter_n - 1'b1;
                pwm_out_n <= 1'b0;  // Keep negative off during dead-time
            end
            else begin
                pwm_out_n <= ~comparison;
            end
        end
    end

endmodule