package carton

import la "core:math/linalg"
import "vendor:OpenGL"

Camera :: struct {
	position:         [3]f32,
	look_at_position: [3]f32,

	look_at_rotator:  [3]f32,
	rotation_order:   Rotation_Order,
	update:           proc(this: ^Camera),
}

@(private)
camera_get_view_matrix :: proc(camera: ^Camera) -> (view_matrix: matrix[4, 4]f32) {
	assert(camera != nil)
	return camera_get_look_at_vec(camera)
}

camera_get_directon :: proc(camera: ^Camera) -> (direction: [3]f32) {
	assert(camera != nil)
	return la.normalize(camera.position - camera.look_at_position)
}

camera_get_right_vec :: proc(camera: ^Camera) -> (right_vec: [3]f32) {
	assert(camera != nil)
	up := [3]f32{0.0, 1.0, 0.0}
	return la.normalize(la.cross(up, camera_get_directon(camera)))
}

camera_get_up_vec :: proc(camera: ^Camera) -> (up_vec: [3]f32) {
	assert(camera != nil)
	return la.normalize(la.cross(camera_get_directon(camera), camera_get_right_vec(camera)))
}

camera_get_look_at_vec :: proc(camera: ^Camera) -> (look_at_vec: matrix[4,4]f32) {
	assert(camera != nil)
	return la.matrix4_look_at_f32(camera.position, camera.look_at_position, camera_get_up_vec(camera))
}
