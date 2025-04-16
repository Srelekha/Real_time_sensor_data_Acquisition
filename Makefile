TOP = top
PCF = vsdsquadron.pcf
VERILOG_SOURCES = top.v uart_tx.v dht11_reader.v

all: ${TOP}.bin

${TOP}.json: ${VERILOG_SOURCES}
	yosys -p "synth_ice40 -top ${TOP} -json ${TOP}.json" ${VERILOG_SOURCES}

${TOP}.asc: ${TOP}.json ${PCF}
	nextpnr-ice40 --hx8k --package ct256 --json ${TOP}.json --pcf ${PCF} --asc ${TOP}.asc

${TOP}.bin: ${TOP}.asc
	icepack ${TOP}.asc ${TOP}.bin

prog: ${TOP}.bin
	iceprog ${TOP}.bin

clean:
	rm -f ${TOP}.json ${TOP}.asc ${TOP}.bin