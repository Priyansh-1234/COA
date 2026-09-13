COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = fast_booth_waves.vcd

SRCS = adder_64.v \
			 booth_encoder_radix4.v \
			 carry_save_adder_64.v \
			 fast_booth_controlpath.v \
			 fast_booth_datapath.v \
			 fast_booth_multiplier_32.v \
			 fast_booth_multiplier_32_tb.v \
			 partial_product_generator.v

all: sim

compile: $(TARGET)

$(TARGET): $(SRCS)
	$(COMPILER) -o $(TARGET) $(SRCS)

sim: compile
	$(SIMULATOR) $(TARGET)

wave: 
	$(VIEWER) $(WAVES) &

clean:
	rm -f $(TARGET) $(WAVES)

.PHONY: all compile sim wave clean

