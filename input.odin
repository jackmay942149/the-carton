package engine

import glfw "vendor:glfw"

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
input_mouse_motion :: proc() -> (x, y: f64){
	return glfw.GetCursorPos(g_window_handle)
}
