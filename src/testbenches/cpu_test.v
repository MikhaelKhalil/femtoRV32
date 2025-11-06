`timescale 1ns / 1ps

module cpu_test();

    reg rclk;
    reg ssd_clk;
    reg rst;
    reg [1:0] ledSel;
    reg [3:0] ssdSel;
    
    wire [15:0] leds;
    wire [6:0] seg;
    wire [3:0] an;

    riscv_top dut(
        .rclk(rclk),
        .ssd_clk(ssd_clk),
        .rst(rst),
        .ledSel(ledSel),
        .ssdSel(ssdSel),
        .leds(leds),
        .seg(seg),
        .an(an)
    );
    
    // RISC-V clock (manual stepping)
    initial begin
        rclk = 0;
        forever #50 rclk = ~rclk;  // 10MHz for manual stepping
    end
    
    // SSD clock (100MHz)
    initial begin
        ssd_clk = 0;
        forever #5 ssd_clk = ~ssd_clk;  // 100MHz
    end
    
    initial begin
        // Initialize inputs
        rst = 1'b1;
        ledSel = 2'b00;
        ssdSel = 4'b0000;

        #100;
        rst = 1'b0;
        
        // Test different LED selections
        #200;
        ledSel = 2'b01;  // Show instruction[31:16]
        
        #200;
        ledSel = 2'b10;  // Show control signals
        
        #200;
        ledSel = 2'b00;  // Back to instruction[15:0]
        
        // Test different SSD selections
        #200;
        ssdSel = 4'b0001;  // PC+4
        
        #200;
        ssdSel = 4'b1010;  // ALU output
        
        #200;
        ssdSel = 4'b0000;  // Back to PC
        
        #1000;
        $finish();
     end
     
endmodule
