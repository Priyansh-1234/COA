COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
TARGET = sim_exec
WAVES = carry_save_adder_waves.vcd

SRCS = carry_save_adder_3x4.v \
			 carry_save_adder_3x4_tb.v \
			 carry_save_stage_4bit.v \
			 half_adder.v \
			 full_adder.v \
			 ripple_carry_adder_5bit.v

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
