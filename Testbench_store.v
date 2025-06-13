`timescale 1ns / 1ps

module Testbench_store();
    reg clk;
    reg resetn;
    wire [15:0] Sine_out, Tri_out;
    wire PWM;

    integer outfile;

    Top uut (
        .clk(clk), 
        .resetn(resetn), 
        .Sine_out(Sine_out), 
        .Tri_out(Tri_out), 
        .PWM(PWM)
    );

    always #10 clk = ~clk;
    
    initial begin
        clk = 0;
        resetn = 0;

        outfile = $fopen("output_data.txt", "w");
        if (outfile == 0) begin
            $display("Error opening file!");
            $finish;
        end

        #20 resetn = 1'b1;

        repeat (100000) begin
            @(posedge clk);
            $fwrite(outfile, "%0dns: Sine_out=%0d, Tri_out=%0d, PWM=%b\n", $time, Sine_out, Tri_out, PWM);
        end

        $fclose(outfile);
        $display("Simulation finished. Output saved to output_data.txt");
        $stop;
    end
endmodule
