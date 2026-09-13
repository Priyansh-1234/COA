COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = hamming74_encoder_waves.vcd

SRCS = hamming74_encoder.v \
			 syndrome_generator.v \
			 hamming74_system.v \
			 hamming74_tb.v

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
