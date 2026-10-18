#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

typedef int i32;
typedef unsigned u32;
typedef size_t usize;
typedef unsigned char u8;

struct File {
  usize size;
  off_t off;
  const u8 *buffer;
};

struct String {
  u8 *bytes;
  usize size;
};

u8 peek(struct File *file) {
  if (file->off == file->size)
    return 0x00;
  return file->buffer[file->off];
}

void advance(struct File *file) {
  if (file->off == file->size) {
    return;
  }
  u8 c = file->buffer[file->off];
  file->off += 1;
}

void advance_till(struct File *file, char c) {
  if (file->off == file->size) {
    return;
  }

  while (file->off < file->size && peek(file) != c) {
    advance(file);
  }
}

int match(struct File *file, u8 c) {
  if (peek(file) != c) {
    return -1;
  }

  advance(file);
  return 0;
}

int consume_token(struct File *file, struct String token) {
  usize matched = 0u;
  off_t start = file->off;

  while (matched < token.size) {
    if (match(file, token.bytes[matched]) < 0) {
      file->off = start;
      return -1;
    }
    matched += 1;
  }

  return 0;
}

int main(int argc, char *argv[]) {
  int err = 0;

  if (argc <= 1) {
    fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
    err = EXIT_FAILURE;
    goto exit_main;
  }

  int fd;
  if ((fd = open(argv[1], O_RDONLY)) == -1) {
    perror("open failed");
    err = EXIT_FAILURE;
    goto exit_main;
  }
  struct stat fs;

  if (fstat(fd, &fs) == -1) {
    perror("fstat failed");
    err = EXIT_FAILURE;
    goto file_close;
  }
  usize file_size = fs.st_size;

  u8 *file = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
  if (file == MAP_FAILED) {
    perror("mmap failed");
    err = EXIT_FAILURE;
    goto file_close;
  }

file_free:
  munmap(file, file_size);
file_close:
  close(fd);
exit_main:
  return err;
}
