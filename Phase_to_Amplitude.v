`timescale 1ns / 1ps

module Phase_to_Amplitude(
    input clk,
    input [9:0] amp_address,
    output reg signed [15:0] amplitude
    );
    
    reg signed [15:0] sine_rom [0:1023];
    /*
    // Wire to capture ROM output
    wire [15:0] rom_out;

    // Instantiate the generated sine ROM IP
    sine_rom_ip sine_rom_uut (
        .clka(clk),
        .addra(amp_address),
        .douta(rom_out)
    );

    always @(posedge clk) begin
        amplitude <= rom_out;
    end
    */
    
    initial begin
        $readmemh("sine_rom_init.mem", sine_rom);
    end

    always @(posedge clk) begin
        amplitude <= sine_rom[amp_address];
    end
endmodule