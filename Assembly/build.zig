const std = @import("std");

pub fn build(b: *std.Build) !void {
    // 1. Initialize the new Zig 0.16 I/O interface using the build allocator
    var threaded = std.Io.Threaded.init(b.allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const target_query = std.Target.Query{
        .cpu_arch = .mips,
        .os_tag = .linux,
        .abi = .musl,
    };
    const target = b.resolveTargetQuery(target_query);
    const optimize = b.standardOptimizeOption(.{});

    // 2. Open the directory using the new std.Io.Dir API 
    // Notice that `io` is passed explicitly to openDir and close
    var src_dir = try std.Io.Dir.cwd().openDir(io, "src", .{ .iterate = true });
    defer src_dir.close(io);

    var it = src_dir.iterate();

    // 3. Iterate over the files (passing `io` to next())
    while (try it.next(io)) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".s")) {
            
            const base_name = entry.name[0 .. entry.name.len - 2];
            const file_path = b.fmt("src/{s}", .{entry.name});

            const exe = b.addExecutable(.{
                .name = base_name,
                .root_module = b.createModule(.{
                    .target = target,
                    .optimize = optimize,
                }),
            });

            exe.root_module.addAssemblyFile(b.path(file_path));
            exe.root_module.addAssemblyFile(b.path("utils/utils.s"));
            exe.root_module.link_libc = false;
            // Positional independent code will not work if you have two files and
            // try to link them against each other
            // I tried so long for /utils/utils.s to link properly with other files
            // and not do some Illegal Instruction 4 or something
            exe.pie = false;

            b.installArtifact(exe);

            const run_cmd = b.addSystemCommand(&.{ "qemu-mips" });
            run_cmd.addArtifactArg(exe);
            run_cmd.step.dependOn(b.getInstallStep());

            const step_name = b.fmt("run-{s}", .{base_name});
            const step_desc = b.fmt("Run {s} using qemu-mips", .{base_name});
            
            const run_step = b.step(step_name, step_desc);
            run_step.dependOn(&run_cmd.step);
        }
    }
}
