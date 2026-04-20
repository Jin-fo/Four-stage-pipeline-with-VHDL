## ============================================================
## Board Configuration
## ============================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## ============================================================
## Clock (100 MHz)
## ============================================================
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 20.000 -name sys_clk [get_ports {clk}]

## ============================================================
## Reset
## ============================================================
set_property PACKAGE_PIN R2 [get_ports {rst_bar}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst_bar}]

## ============================================================
## Enable (FIXED: must match HDL exactly)
## ============================================================
set_property PACKAGE_PIN T1 [get_ports {enable}]
set_property IOSTANDARD LVCMOS33 [get_ports {enable}]

## ============================================================
## UART RX
## ============================================================
set_property PACKAGE_PIN B18 [get_ports {rx}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx}]

## ============================================================
## UART LOAD INSTRUCTION DONE
## ============================================================
set_property PACKAGE_PIN U7 [get_ports {loaded}]
set_property IOSTANDARD LVCMOS33 [get_ports {loaded}]

set_property PACKAGE_PIN W7 [get_ports {usart}]
set_property IOSTANDARD LVCMOS33 [get_ports {usart}]

set_property PACKAGE_PIN V8 [get_ports {cpu}]
set_property IOSTANDARD LVCMOS33 [get_ports {cpu}]

## ============================================================
## Control signal
## ============================================================
set_property PACKAGE_PIN U18 [get_ports {reg_tog}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_tog}]

## ============================================================
## Inputs - reg_pos[7:0]
## ============================================================
set_property PACKAGE_PIN W13 [get_ports {reg_pos[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[7]}]

set_property PACKAGE_PIN W14 [get_ports {reg_pos[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[6]}]

set_property PACKAGE_PIN V15 [get_ports {reg_pos[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[5]}]

set_property PACKAGE_PIN W15 [get_ports {reg_pos[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[4]}]

set_property PACKAGE_PIN W17 [get_ports {reg_pos[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[3]}]

set_property PACKAGE_PIN W16 [get_ports {reg_pos[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[2]}]

set_property PACKAGE_PIN V16 [get_ports {reg_pos[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[1]}]

set_property PACKAGE_PIN V17 [get_ports {reg_pos[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[0]}]

## ============================================================
## Outputs - reg_value[15:0]
## ============================================================
set_property PACKAGE_PIN L1  [get_ports {reg_value[15]}]
set_property PACKAGE_PIN P1  [get_ports {reg_value[14]}]
set_property PACKAGE_PIN N3  [get_ports {reg_value[13]}]
set_property PACKAGE_PIN P3  [get_ports {reg_value[12]}]
set_property PACKAGE_PIN U3  [get_ports {reg_value[11]}]
set_property PACKAGE_PIN W3  [get_ports {reg_value[10]}]
set_property PACKAGE_PIN V3  [get_ports {reg_value[9]}]
set_property PACKAGE_PIN V13 [get_ports {reg_value[8]}]
set_property PACKAGE_PIN V14 [get_ports {reg_value[7]}]
set_property PACKAGE_PIN U14 [get_ports {reg_value[6]}]
set_property PACKAGE_PIN U15 [get_ports {reg_value[5]}]
set_property PACKAGE_PIN W18 [get_ports {reg_value[4]}]
set_property PACKAGE_PIN V19 [get_ports {reg_value[3]}]
set_property PACKAGE_PIN U19 [get_ports {reg_value[2]}]
set_property PACKAGE_PIN E19 [get_ports {reg_value[1]}]
set_property PACKAGE_PIN U16 [get_ports {reg_value[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[*]}]