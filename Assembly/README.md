# CS39001: Computer Organization and Architecture Lab

## Requirements
To run these programs, you will need:
*   **Zig Compiler:** Version `0.16.0`
*   **QEMU Emulator:** Specifically `qemu-mips` (or the full emulator suite)

## How to Run the Programs
To build all the programs in the repository, run:
```bash
zig build
```

To build and run a specific assignment, use:
```bash
zig build run-{assignment_name}
```

## Important Notes
*   **Linux MIPS vs. SPIM:** I have written these programs not for SPIM, but rather for Linux running on the MIPS architecture. Therefore, the syscalls here will be different from what you find in the lab.
*   **Value in the Linux Version:** This will give you an idea of what syscalls Linux supports and how to call them by setting up the specific registers.
*   **Core Logic:** The rest of the logic and assembly code structure should stay similar to SPIM.

## Plagiarism
Mostly Professors won't ask the same question every year so this repo can't be used for plagarism.
Just use it to learn about writing assembly.

So, the SPIM-supported file for any program can be found under the `spim/` directory under the name `{assignment_name}.spim.S`.

## Directory Structure
*   `build.zig`: File specifying how to build all the programs.
*   `build.zig.zon`: This file gives metadata about the project. It is not important to understand, but do not remove it, otherwise `zig build` will not work.
*   `src/`: Main directory where the Linux MIPS solutions reside.
*   `zig-out/bin/`: Where the final output binaries will be generated.
*   `spim/`: Solutions for the assignments that "should" work on SPIM. I have no way to check these on my machine.
