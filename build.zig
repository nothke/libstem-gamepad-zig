const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const project_name = "gamepad";
    const version_major: u32 = 1;
    const version_minor: u32 = 4;
    const version_tweak: u32 = 2;

    const mod = b.addModule("libstem_gamepad", .{ .target = target, .optimize = optimize });

    // Library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "stem_" ++ project_name,
        .root_module = mod,
    });

    // Common sources
    lib.addCSourceFile(.{
        .file = b.path("source/gamepad/Gamepad_private.c"),
        .flags = &.{},
    });

    // Platform specific sources
    const os_tag = target.result.os.tag;
    switch (os_tag) {
        .macos => lib.addCSourceFile(.{
            .file = b.path("source/gamepad/Gamepad_macosx.c"),
            .flags = &.{},
        }),
        .linux => lib.addCSourceFile(.{
            .file = b.path("source/gamepad/Gamepad_linux.c"),
            .flags = &.{},
        }),
        .windows => lib.addCSourceFile(.{
            .file = b.path("source/gamepad/Gamepad_windows_dinput.c"),
            .flags = &.{},
        }),
        else => {},
    }

    // Preprocessor defines
    mod.addCMacro("VERSION_MAJOR", std.fmt.comptimePrint("{d}", .{version_major}));
    mod.addCMacro("VERSION_MINOR", std.fmt.comptimePrint("{d}", .{version_minor}));
    mod.addCMacro("VERSION_TWEAK", std.fmt.comptimePrint("{d}", .{version_tweak}));

    // Platform-specific link flags
    switch (os_tag) {
        .macos => {
            lib.linkFramework("IOKit");
        },
        .linux => {
            lib.linkSystemLibrary("pthread");
        },
        .windows => {
            lib.linkLibC();
            lib.linkSystemLibrary("xinput1_4");
            lib.linkSystemLibrary("dinput8");
            lib.linkSystemLibrary("dxguid");
            lib.linkSystemLibrary("WbemUuid");
            lib.linkSystemLibrary("Ole32");
            lib.linkSystemLibrary("OleAut32");
            mod.addCMacro("FREEGLUT_STATIC", "1");
        },
        else => {},
    }

    lib.installHeadersDirectory(b.path("source/gamepad"), "", .{});

    const lib_artifact = b.addInstallArtifact(lib, .{});

    // Test harness executable
    const exe = b.addExecutable(.{
        .name = "gamepad_testharness",
        .root_module = b.createModule(.{
            .root_source_file = null,
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.addCSourceFile(.{ .file = b.path("source/testharness/TestHarness_main.c") });
    exe.linkLibrary(lib);

    switch (target.result.os.tag) {
        .macos => {
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("OpenGL");
            exe.linkFramework("GLUT");
            exe.linkFramework("ApplicationServices");
        },
        .linux => {
            exe.linkSystemLibrary("glut");
            exe.linkSystemLibrary("GLU");
            exe.linkSystemLibrary("GL");
        },
        .windows => {
            exe.linkSystemLibrary("freeglut64_static");
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("glu32");
            exe.linkSystemLibrary("pthread");
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
        },
        else => {},
    }

    const exe_artifact = b.addInstallArtifact(exe, .{});

    // Default step builds and installs both
    b.getInstallStep().dependOn(&lib_artifact.step);
    b.getInstallStep().dependOn(&exe_artifact.step);
}
