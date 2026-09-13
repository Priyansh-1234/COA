COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = booth_multiplier_4bit_waves.vcd

SRCS = booth_multiplier_4bit.v \
			 booth_tb.v \
			 clock_divider.v

all: sim

compile:
	$(COMPILER) -o $(TARGET) $(SRCS)

sim: compile
	$(SIMULATOR) $(TARGET)

wave: sim
	$(VIEWER) $(WAVES) &

clean:
	rm -f $(TARGET) $(WAVES)

.PHONY: all compile sim wave clean
