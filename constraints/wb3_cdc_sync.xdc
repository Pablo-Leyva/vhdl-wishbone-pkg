set_property DONT_TOUCH TRUE [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]

set_false_path -through [get_pins -filter {NAME=~*wb_a_m2s[addr]*} -of [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]]
set_false_path -through [get_pins -filter {NAME=~*wb_a_m2s[data]*} -of [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]]
set_false_path -through [get_pins -filter {NAME=~*wb_a_m2s[sel]*}  -of [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]]
set_false_path -through [get_pins -filter {NAME=~*wb_a_m2s[we]*}   -of [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]]

set_false_path -through [get_pins -filter {NAME=~*wb_b_s2m[data]*} -of [get_cells -hier -filter {NAME=~*wb3_cdc_sync}]]
