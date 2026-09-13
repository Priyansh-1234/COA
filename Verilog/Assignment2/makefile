# Variables
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = code_converter_top_waves.vcd

# List of all Verilog source files
SRCS = binary_to_gray.v \
			 gray_to_binary.v \
			 code_converter_top.v \
			 code_converter_top_tb.v

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
