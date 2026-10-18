CC = gcc-13
CFLAGS = -Wall -Wextra -Werror

SRCS = assembler.c
OBJS = $(SRCS:.c=.o)
TARGET = asm

all: compile

compile: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)
