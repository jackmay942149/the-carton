package carton

import glfw "vendor:glfw"

Scene :: struct {
	window: glfw.WindowHandle,
	camera: Camera,
	entities: []Entity,
	ui: UI,
}
