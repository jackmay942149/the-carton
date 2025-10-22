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
	// view_matrix = la.identity(matrix[4, 4]f32)

	// // Perform first rotation
	// if camera.rotation_order == .XYZ || camera.rotation_order == .XZY {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	// } else if camera.rotation_order == .YXZ || camera.rotation_order == .YZX {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	// } else if camera.rotation_order == .ZXY || camera.rotation_order == .ZYX {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	// }

	// // Perform second rotation
	// if camera.rotation_order == .YXZ || camera.rotation_order == .ZXY {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	// } else if camera.rotation_order == .XYZ || camera.rotation_order == .ZYX {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	// } else if camera.rotation_order == .XZY || camera.rotation_order == .YZX {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	// }

	// // Perform thrid rotation
	// if camera.rotation_order == .YZX || camera.rotation_order == .ZYX {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	// } else if camera.rotation_order == .XZY || camera.rotation_order == .ZXY {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	// } else if camera.rotation_order == .XYZ || camera.rotation_order == .YXZ {
	// 	view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	// }
	
	// view_matrix = la.matrix4_translate(camera.position) * view_matrix
	// view_matrix = la.matrix4_translate(camera.look_at_position) * view_matrix
}

camera_get_directon :: proc(camera: ^Camera) -> (direction: [3]f32) {
	assert(camera != nil)
	return camera.position - camera.look_at_position
}

camera_get_right_vec :: proc(camera: ^Camera) -> (right_vec: [3]f32) {
	assert(camera != nil)
	up := [3]f32{0.0, 1.0, 0.0}
	return la.normalize(la.cross(up, camera_get_directon(camera)))
}

@(private)
camera_get_up_vec :: proc(camera: ^Camera) -> (up_vec: [3]f32) {
	assert(camera != nil)
	return la.cross(camera_get_directon(camera), camera_get_right_vec(camera))
}

camera_get_look_at_vec :: proc(camera: ^Camera) -> (look_at_vec: matrix[4,4]f32) {
	assert(camera != nil)
	return la.matrix4_look_at_f32(camera.position, camera.look_at_position, camera_get_up_vec(camera))
}
