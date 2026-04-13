## Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## Reset
set_property PACKAGE_PIN R2 [get_ports rst_bar]
set_property IOSTANDARD LVCMOS33 [get_ports rst_bar]

## Enable Switch
set_property PACKAGE_PIN T1 [get_ports en_bar]
set_property IOSTANDARD LVCMOS33 [get_ports en_bar]

## UART RX (USB-UART)
set_property PACKAGE_PIN B18 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

## DATA BITS
## LED 0
set_property PACKAGE_PIN U16 [get_ports {rx_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[0]}]

## LED 1
set_property PACKAGE_PIN E19 [get_ports {rx_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[1]}]

## LED 2
set_property PACKAGE_PIN U19 [get_ports {rx_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[2]}]

## LED 3
set_property PACKAGE_PIN V19 [get_ports {rx_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[3]}]

## LED 4
set_property PACKAGE_PIN W18 [get_ports {rx_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[4]}]

## LED 5
set_property PACKAGE_PIN U15 [get_ports {rx_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[5]}]

## LED 6
set_property PACKAGE_PIN U14 [get_ports {rx_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[6]}]

## LED 7
set_property PACKAGE_PIN V14 [get_ports {rx_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[7]}]

## LED 15 (rx_ready MSB)
set_property PACKAGE_PIN L1 [get_ports {rx_ready}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_ready}]