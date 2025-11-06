
PROGRAM=fpga_6502

default:
	yosys -q \
	  -p "synth_gowin -top $(PROGRAM) -json $(PROGRAM).json -family gw1n" \
	  src/$(PROGRAM).v src/ALU.v src/cpu_65c02.v src/rom.v src/ram.v src/uart_tx.v src/uart_rx.v
	nextpnr-himbaechel -r \
	  --json $(PROGRAM).json \
	  --write $(PROGRAM)_pnr.json \
	  --freq 27 \
	  --vopt family=GW1N-9C \
	  --vopt cst=tangnano9k.cst \
	  --device GW1NR-LV9QN88PC6/I5
	gowin_pack -d GW1N-9C -o $(PROGRAM).fs $(PROGRAM)_pnr.json

compile:
	naken_asm -o test/rom.bin -type bin -l test/counter.asm
	hexdump -v -e '16/1 "%02X " "\n"' test/rom.bin > src/rom.hex
	@echo "Assembled!"

clean:
	@rm -f $(PROGRAM).fs $(PROGRAM).json $(PROGRAM)_pnr.json $(PROGRAM).asc
	@echo "Clean!"

