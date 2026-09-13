COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = bidirectional_led_shift_waves.vcd

SRCS = bidirectional_led_shift.v \
			 bidirectional_tb.v \
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
