const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});
pub fn main() !void {
    std.debug.print("Testing\n", .{});

    const window = glfw.glfwCreateWindow(1200, 900, "Demo", null, null);
    glfw.glfwMakeContextCurrent(window);
    glfw.glfwSwapInterval(1);

    std.debug.print("Start sleep\n", .{});
    std.time.sleep(2000000000);
    std.debug.print("Stop sleep\n", .{});
    glfw.glfwTerminate();
}
