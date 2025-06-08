`timescale 1ns / 1ps

module DDS_Module(
    input  clk,
    input  resetn,
    output [15:0] Sine_out
    );
    
    reg  [23:0] FCW;
    reg  [23:0] Accm;
    wire [9:0]  Sine_addr;
    
    assign Sine_addr = Accm [23:14];
    
    SineROM sine_rom_inst (
        .clka(clk),
        .ena(1'b1),
        .addra(Sine_addr),
        .douta(Sine_out)
    );
    
    always @(posedge clk or negedge resetn) begin 
        if(!resetn) begin
            Accm <= 24'b0;
            FCW  <= 24'd671088;
        end
        else begin 
            Accm <= Accm + FCW;
        end
    end 
endmodule