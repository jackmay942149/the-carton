package engine

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

g_mouse_pos: [2]f64

@(private)
window_update :: proc(scene: ^Scene) {
	assert(scene != nil)
	#partial switch g_graphics_api {
		case .OpenGL: opengl_update(scene)
	}
	glfw.SwapBuffers(g_window_handle)
	glfw.PollEvents()

	mouse_pos_x, mouse_pos_y := input_mouse_motion()

	if input_is_key_down(.LEFT_ALT) && input_is_mouse_down(.LEFT) {
		scene.camera.look_at_rotator.y -= f32(g_mouse_pos.x - mouse_pos_x)/5
		scene.camera.look_at_rotator.x -= f32(g_mouse_pos.y - mouse_pos_y)/5
	}
	g_mouse_pos = {mouse_pos_x, mouse_pos_y}
}

