package engine

import log  "core:log"
import glfw "vendor:glfw"
import gl   "vendor:OpenGL"
import la   "core:math/linalg"


@(private)
opengl_init :: proc() {
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
	gl.Enable(gl.DEPTH_TEST)
}

@(private)
opengl_update :: proc(entity: ^Entity) {
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	gl.UseProgram(entity.mesh.material.shader)
	gl.BindTexture(gl.TEXTURE_2D, entity.mesh.material.texture)
	gl.BindVertexArray(entity.mesh.vao)

	transform := gl.GetUniformLocation(entity.mesh.material.shader, "uni_transform")
	model_mat := la.identity(matrix[4, 4]f32)
	model_mat = la.matrix4_rotate(entity.rotation, [3]f32{0, 0, 1}) * model_mat

	view_mat := la.identity(matrix[4, 4]f32)
	view_mat = la.matrix4_translate([3]f32{0, 0, -100}) * view_mat

	projection_mat := la.identity(matrix[4, 4]f32)
	projection_mat = la.matrix4_perspective(f32(la.to_radians(45.0)), 800/680, 0.1, 1000)

	transform_mat := projection_mat * view_mat * model_mat
	gl.UniformMatrix4fv(transform, 1, false, raw_data(&transform_mat))
	gl.DrawElements(gl.TRIANGLES, i32(len(entity.mesh.indices)), gl.UNSIGNED_INT, nil)

	entity.rotation += 0.0001
}
