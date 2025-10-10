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
opengl_update :: proc(scene: ^Scene) {
	assert(scene != nil)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	view_mat := camera_get_view_matrix(&scene.camera)
	
	for &entity in scene.entities {
		if entity.update != nil {
			entity.update(&entity)
		}

		
		gl.UseProgram(entity.mesh.material.shader)
		gl.BindTexture(gl.TEXTURE_2D, entity.mesh.material.texture)
		gl.BindVertexArray(entity.mesh.vao)

		if entity.mesh.needs_update {
			gl.BindBuffer(gl.ARRAY_BUFFER, entity.mesh.vbo)
			gl.BufferData(gl.ARRAY_BUFFER, len(entity.mesh.vertices) * size_of(Vertex), &entity.mesh.vertices[0], gl.DYNAMIC_DRAW)
		}

		model := gl.GetUniformLocation(entity.mesh.material.shader, "uni_model")
		view := gl.GetUniformLocation(entity.mesh.material.shader, "uni_view")
		projection := gl.GetUniformLocation(entity.mesh.material.shader, "uni_projection")

		model_mat := la.identity(matrix[4, 4]f32)
		model_mat = la.matrix4_rotate(entity.rotation, [3]f32{0, 1, 0}) * model_mat
		model_mat = la.matrix4_translate(entity.position) * model_mat

		projection_mat := la.matrix4_perspective(f32(la.to_radians(45.0)), 1600.0/900.0, 0.1, 1000)

		gl.UniformMatrix4fv(model, 1, false, raw_data(&model_mat))
		gl.UniformMatrix4fv(view, 1, false, raw_data(&view_mat))
		gl.UniformMatrix4fv(projection, 1, false, raw_data(&projection_mat))
		gl.DrawElements(gl.TRIANGLES, i32(len(entity.mesh.indices)), gl.UNSIGNED_INT, nil)
	}

}
