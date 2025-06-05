`timescale 1ns / 1ps

module DDS_Testbench();
    reg clk;
    reg reset;
    reg  [23:0] FCW;
    wire signed [15:0] sine_out;
    
     DDS_Top uut (
        .clk(clk),
        .reset(reset),
        .FCW(FCW),
        .sine_out(sine_out)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk   = 1'b0;
        reset = 1'b1;
        FCW   = 24'd0;
        
        #50;
        reset = 1'b0;
        
        FCW = 24'd100;  // small step size
        #50000;
        
        FCW = 24'd10000;  // Medium step size
        #50000;
        
        FCW = 24'd1000000;
        #50000;
        
        reset = 1;
        #20;
        $finish;
     end
endmodule
