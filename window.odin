package carton

import glfw "vendor:glfw"
import str  "core:strings"
import gl   "vendor:OpenGL"
import log  "core:log"

g_window_handle: glfw.WindowHandle
g_graphics_api:  Graphics_Api

@(private)
window_init :: proc(width, height: int, title: string, api: Graphics_Api, allocator := context.allocator) {
	context.allocator = allocator
	glfw.WindowHint(glfw.CLIENT_API, 0)
	glfw.WindowHint(glfw.RESIZABLE, false)

	assert(glfw.Init() == true)
	titlen := str.clone_to_cstring(title)
	g_window_handle = glfw.CreateWindow(i32(width), i32(height), titlen, nil, nil)
	glfw.MakeContextCurrent(g_window_handle)
	glfw.SwapInterval(1)
	glfw.SetScrollCallback(g_window_handle, input_scroll_callback)

	g_graphics_api = api
	#partial switch api {
		case .Vulkan: {
			vulkan_init(title)
		}
		case .OpenGL: {
			opengl_init()
		}
	}
}

@(private)
window_destroy :: proc() {
	glfw.DestroyWindow(g_window_handle)
	glfw.Terminate()
}

@(private)
window_should_close :: proc() -> bool {
	return bool(glfw.WindowShouldClose(g_window_handle))
}

@(private)
window_close :: proc() {
	glfw.SetWindowShouldClose(g_window_handle, true)
}


@(private)
window_update :: proc(scene: ^Scene) {
	assert(scene != nil)
	#partial switch g_graphics_api {
		case .OpenGL: opengl_update(scene)
	}
	glfw.SwapBuffers(g_window_handle)
	glfw.PollEvents()
	input_update_mouse_info()
}

