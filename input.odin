package carton

import glfw "vendor:glfw"

@(private)
g_old_mouse_pos: [2]f64
g_scroll_input: [2]f64

@(private)
input_is_key_down :: proc(key: Key) -> bool {
	state := glfw.GetKey(g_window_handle, i32(key))
	if state == glfw.PRESS {
		return true
	}
	return false
}

@(private)
input_is_mouse_down :: proc(mb: Mouse_Button) -> bool {
	state := glfw.GetMouseButton(g_window_handle, i32(mb))
	if state == glfw.PRESS {
		return true
	}
	return false
}

@(private)
input_mouse_position :: proc() -> (x, y: f64) {
	return glfw.GetCursorPos(g_window_handle)
}

@(private)
input_mouse_delta :: proc() -> (x, y: f64) {
	new_pos: [2]f64
	new_pos.x, new_pos.y = input_mouse_position()
	mouse_delta := new_pos - g_old_mouse_pos
	g_old_mouse_pos = new_pos
	return mouse_delta.x, mouse_delta.y
}

@(private)
input_update_mouse_info :: proc() {
	g_old_mouse_pos.x, g_old_mouse_pos.y = input_mouse_position()
}

@(private)
input_scroll_callback :: proc "c" (window_handle: glfw.WindowHandle, x, y: f64) {
	g_scroll_input.x = x
	g_scroll_input.y = y
}

@(private)
input_get_scroll :: proc() -> (x, y: f32) {
	x = f32(g_scroll_input.x)
	y = f32(g_scroll_input.y)
	g_scroll_input = {0, 0}
	return x, y
}
