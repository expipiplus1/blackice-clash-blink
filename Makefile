chip.bin: top.v verilog/Reset/Reset_topEntity.v blackice.pcf verilog/Blink/Blink_topEntity.v blackice.pcf
	yosys -q -p "synth_ice40 -blif chip.blif" top.v verilog/Reset/Reset_topEntity.v verilog/Blink/Blink_topEntity.v
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

verilog/Reset/Reset_topEntity.v: Reset.hs
	clash --verilog Reset.hs

verilog/Blink/Blink_topEntity.v: Blink.hs
	clash --verilog Blink.hs

.PHONY: clean
clean:
	$(RM) -rf chip.blif chip.txt chip.ex chip.bin verilog *.dyn_hi *.dyn_o *.hi *.o
