package engine

import glfw "vendor:glfw"
import str  "core:strings"
import gl "vendor:OpenGL"

g_window_handle: glfw.WindowHandle

@(export)
window_init :: proc(width, height: int, title: string, allocator := context.allocator) {
	context.allocator = allocator
	glfw.WindowHint(glfw.CLIENT_API, 0)
	glfw.WindowHint(glfw.RESIZABLE, false)

	assert(glfw.Init() == true)
	titlen := str.clone_to_cstring(title)
	g_window_handle = glfw.CreateWindow(i32(width), i32(height), titlen, nil, nil)
	glfw.MakeContextCurrent(g_window_handle)

	vulkan_init(title)
}

@(export)
window_destroy :: proc() {
	glfw.DestroyWindow(g_window_handle)
	glfw.Terminate()
}

@(export)
window_should_close :: proc() -> bool {
	return bool(glfw.WindowShouldClose(g_window_handle))
}

@(export)
window_update :: proc() {
	glfw.SwapBuffers(g_window_handle)
	glfw.PollEvents()
}

