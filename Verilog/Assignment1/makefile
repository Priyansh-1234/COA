# Variables
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = logic_unit_waves.vcd

# List of all Verilog source files
SRCS = half_adder.v \
       full_adder.v \
       ripple_carry_adder_4bit.v \
       and_4bit.v \
       or_4bit.v \
       xor_4bit.v \
       mux4to1_5bit.v \
       logic_unit.v \
       logic_unit_tb.v

# Default rule executed when typing 'make'
all: sim

# 1. Compile the Verilog files into an executable
compile:
	$(COMPILER) -o $(TARGET) $(SRCS)

# 2. Run the simulation (generates the .vcd file)
sim: compile
	$(SIMULATOR) $(TARGET)

# 3. Open the waveform viewer
wave: sim
	$(VIEWER) $(WAVES) &

# 4. Clean up generated files
clean:
	rm -f $(TARGET) $(WAVES)

.PHONY: all compile sim wave clean
