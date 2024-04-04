const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "shared", "Build as a shared library") orelse false;
    const use_opengl = b.option(bool, "opengl", "Build with OpenGL") orelse false;
    const use_gles = b.option(bool, "gles", "Build with GLES") orelse false;
    const lib = std.Build.Step.Compile.create(b, .{
        .name = "glfw3",
        .kind = .lib,
        .linkage = if (shared) .dynamic else .static,
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = "include" });
    lib.linkLibC();
    if (shared) lib.defineCMacro("_GLFW_BUILD_DLL", "1");

    lib.installHeadersDirectory("include/GLFW", "GLFW");
    const vulkan_headers_dep = b.dependency("vulkan_headers", .{
        .target = target,
        .optimize = optimize,
    });

    lib.installLibraryHeaders(vulkan_headers_dep.artifact("vulkan-headers"));
    if (target.os_tag == .linux) {
        const x11_headers_dep = b.dependency("x11_headers", .{
            .target = target,
            .optimize = optimize,
        });
        const wayland_headers_dep = b.dependency("wayland_headers", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(x11_headers_dep.artifact("x11-headers"));
        lib.linkLibrary(wayland_headers_dep.artifact("wayland-headers"));
        lib.installLibraryHeaders(x11_headers_dep.artifact("x11-headers"));
        lib.installLibraryHeaders(wayland_headers_dep.artifact("wayland-headers"));
    }
    const include_src_flag = "-Isrc";

    lib.linkSystemLibrary("gdi32");
    lib.linkSystemLibrary("user32");
    lib.linkSystemLibrary("shell32");
    if (use_opengl) {
        lib.linkSystemLibrary("opengl32");
    }
    if (use_gles) {
        lib.linkSystemLibrary("GLESv3");
    }
    const flags = [_][]const u8{ "-D_GLFW_WIN32", include_src_flag };
    lib.addCSourceFiles(&base_source_files, &flags);
    lib.addCSourceFiles(&windows_source_files, &flags);
    b.installArtifact(lib);

    // lib.addCSourceFiles(&base_source_files, &c_flags);
    // t.addCSourceFiles(&windows_source_files, &c_flags);

    // lib.addIncludePath(.{ .path = "./include/" });
    // lib.addIncludePath(.{ .path = "./src/" });
    // lib.linkLibC();

    // t.addIncludePath(.{ .path = "./include/" });
    // t.addIncludePath(.{ .path = "./src/" });
    // t.linkLibC();

    // if (lib.optimize != .Debug)
    //     lib.strip = true;

    // t.linkLibrary(lib);

    // b.installArtifact(t);
}
const base_source_files = [_][]const u8{
    // .c files for all targets (https://github.com/glfw/glfw/blob/076bfd55be45e7ba5c887d4b32aa03d26881a1fb/src/CMakeLists.txt#L4)
    "src/context.c",
    "src/egl_context.c",
    "src/init.c",
    "src/input.c",
    "src/monitor.c",
    "src/null_init.c",
    "src/null_joystick.c",
    "src/null_monitor.c",
    "src/null_window.c",
    "src/osmesa_context.c",
    "src/platform.c",
    "src/vulkan.c",
    "src/window.c",
};
const windows_source_files = [_][]const u8{
    // .c files for windows build (https://github.com/glfw/glfw/blob/076bfd55be45e7ba5c887d4b32aa03d26881a1fb/src/CMakeLists.txt#L14)
    "src/wgl_context.c",
    "src/win32_init.c",
    "src/win32_joystick.c",
    "src/win32_module.c",
    "src/win32_monitor.c",
    "src/win32_thread.c",
    "src/win32_time.c",
    "src/win32_window.c",
};
const c_flags = [_][]const u8{
    // when compiling this lib in debug mode, it seems to add -fstack-protector so if you want to link it
    // with an exe built with -Dtarget=x86_64-windows-msvc you need the line below or you'll get undefined symbols
    "-fno-stack-protector",
    // don't want to add some functions (__mingw_vsscanf etc.), also needed for building exe with msvc abi
    "-D_STDIO_DEFINED",
    // we're compiling for windows (https://github.com/glfw/glfw/blob/076bfd55be45e7ba5c887d4b32aa03d26881a1fb/src/glfw_config.h.in#L40) _GLFW_USE_CONFIG_H is used to get this define in cmake
    "-D_GLFW_WIN32",
    // added to windows builds (https://github.com/glfw/glfw/blob/076bfd55be45e7ba5c887d4b32aa03d26881a1fb/src/CMakeLists.txt#L144)
    "-D_UNICODE",
    "-DUNICODE",
};
