package carton

import la "core:math/linalg"

Rotation_Order :: enum {
	XYZ,
	XZY,
	YXZ,
	YZX,
	ZXY,
	ZYX,
}

rotate_point_around_pivot :: proc(point, pivot, axis: [3]f32, angle: f32) ->  [3]f32 {
	local_pos := point - pivot
	rot_mat := la.matrix4_rotate_f32(angle, axis)
	rotated_pos := rot_mat * [4]f32{local_pos.x, local_pos.y, local_pos.z, 1.0}
	new_pos := rotated_pos + [4]f32{pivot.x, pivot.y, pivot.z, 1.0}
	return new_pos.xyz
}
