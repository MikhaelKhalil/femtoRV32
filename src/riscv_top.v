`timescale 1ns / 1ps

module riscv_top(
    input rclk,
    input ssd_clk,
    
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
   
    output [15:0] leds,
   
    output [6:0] seg,
    output [3:0] an
    );

    wire [12:0] ssd_data;

    cpu cpu_inst (
        .clk(rclk),
        .rst(rst),
        .ledSel(ledSel),
        .ssdSel(ssdSel),
        .leds(leds),
        .ssd(ssd_data)
    );

    Four_Digit_Seven_Segment_Driver_Optimized ssd_inst (
        .clk(ssd_clk),
        .num(ssd_data),
        .Anode(an),
        .LED_out(seg)
    );

endmodule
