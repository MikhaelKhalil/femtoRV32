set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { ssd_clk }];
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports ssd_clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports ssd_clk]

# RISC-V clock (manual stepping via push button)
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports rclk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rclk]

# Reset button
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports rst]

set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { ledSel[0] }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { ledSel[1] }];

set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { ssdSel[0] }];
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { ssdSel[1] }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ssdSel[2] }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { ssdSel[3] }];

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { leds[0] }];
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { leds[1] }];
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { leds[2] }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { leds[3] }];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { leds[4] }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { leds[5] }];
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { leds[6] }];
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { leds[7] }];
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { leds[8] }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { leds[9] }];
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { leds[10] }];
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { leds[11] }];
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { leds[12] }];
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { leds[13] }];
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { leds[14] }];
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { leds[15] }];

set_property -dict { PACKAGE_PIN T10    IOSTANDARD LVCMOS33 } [get_ports { seg[6] }];
set_property -dict { PACKAGE_PIN R10    IOSTANDARD LVCMOS33 } [get_ports { seg[5] }];
set_property -dict { PACKAGE_PIN K16    IOSTANDARD LVCMOS33 } [get_ports { seg[4] }];
set_property -dict { PACKAGE_PIN K13    IOSTANDARD LVCMOS33 } [get_ports { seg[3] }];
set_property -dict { PACKAGE_PIN P15    IOSTANDARD LVCMOS33 } [get_ports { seg[2] }];
set_property -dict { PACKAGE_PIN T11    IOSTANDARD LVCMOS33 } [get_ports { seg[1] }];
set_property -dict { PACKAGE_PIN L18    IOSTANDARD LVCMOS33 } [get_ports { seg[0] }];

set_property -dict { PACKAGE_PIN J17    IOSTANDARD LVCMOS33 } [get_ports { an[0] }];
set_property -dict { PACKAGE_PIN J18    IOSTANDARD LVCMOS33 } [get_ports { an[1] }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { an[2] }];
set_property -dict { PACKAGE_PIN J14    IOSTANDARD LVCMOS33 } [get_ports { an[3] }];

# BYPASSING COMBINATIONAL LOOP (ALREADY TAKEN CARE OF THAT IN THE IMPLEMENTATION)
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets cpu_inst/if_id/loop[4].generating/regwrite2]
