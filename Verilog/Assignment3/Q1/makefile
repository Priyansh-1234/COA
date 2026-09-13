COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = array_multiplier_3bit.vcd

SRCS = array_multiplier_3bit.v \
			 half_adder.v \
			 full_adder.v \
			 array_multiplier_3bit_tb.v 

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
