package engine

import la "core:math/linalg"

Camera :: struct {
	position:         [3]f32,
	look_at_position: [3]f32,
	look_at_rotator:  [3]f32,
	rotation_order:   Rotation_Order,
}

@(private)
camera_get_view_matrix :: proc(camera: ^Camera) -> (view_matrix: matrix[4, 4]f32) {
	assert(camera != nil)
	view_matrix = la.identity(matrix[4, 4]f32)

	// Perform first rotation
	if camera.rotation_order == .XYZ || camera.rotation_order == .XZY {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	} else if camera.rotation_order == .YXZ || camera.rotation_order == .YZX {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	} else if camera.rotation_order == .ZXY || camera.rotation_order == .ZYX {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	}

	// Perform second rotation
	if camera.rotation_order == .YXZ || camera.rotation_order == .ZXY {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	} else if camera.rotation_order == .XYZ || camera.rotation_order == .ZYX {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	} else if camera.rotation_order == .XZY || camera.rotation_order == .YZX {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	}

	// Perform thrid rotation
	if camera.rotation_order == .YZX || camera.rotation_order == .ZYX {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.x)), {1, 0, 0}) * view_matrix
	} else if camera.rotation_order == .XZY || camera.rotation_order == .ZXY {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.y)), {0, 1, 0}) * view_matrix
	} else if camera.rotation_order == .XYZ || camera.rotation_order == .YXZ {
		view_matrix = la.matrix4_rotate_f32(la.to_radians(f32(camera.look_at_rotator.z)), {0, 0, 1}) * view_matrix
	}
	
	view_matrix = la.matrix4_translate(camera.position) * view_matrix
	return view_matrix
}
