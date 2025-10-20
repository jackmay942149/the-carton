package carton

import gl "vendor:OpenGL"
import fmt "core:fmt"
import la "core:math/linalg"

UI_Box :: struct {
	using atom: UI_Atom,
	name: string,
	color: [4]f32,
}

box_create :: proc(name: string, color: [4]f32, position: [2]f32, size: [2]f32) -> (box: UI_Box) {
	box.color = color
	box.draw = box_draw
	box.name = name
	box.position = position
	box.size = size

	mesh := make([]Vertex, 4)
	mesh[0] = Vertex {
		position = {position.x - size.x/2, position.y - size.y/2, 0.0},
		colour = box.color.rgb,
	}
	mesh[1] = Vertex {
		position = {position.x + size.x/2, position.y - size.y/2, 0.0},
		colour = box.color.rgb,
	}
	mesh[2] = Vertex {
		position = {position.x + size.x/2, position.y + size.y/2, 0.0},
		colour = box.color.rgb,
	}
	mesh[3] = Vertex {
		position = {position.x - size.x/2, position.y + size.y/2, 0.0},
		colour = box.color.rgb,
	}
	indices := make([]u32, 6)
	indices[0] = 0
	indices[1] = 1
	indices[2] = 2
	indices[3] = 0
	indices[4] = 2
	indices[5] = 3

	gl.GenVertexArrays(1, &box.mesh.vao)
	gl.BindVertexArray(box.mesh.vao)

	gl.GenBuffers(1, &box.mesh.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, box.mesh.vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(mesh) * size_of(Vertex), &mesh[0], gl.DYNAMIC_DRAW)

	gl.GenBuffers(1, &box.mesh.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, box.mesh.ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(i32), &indices[0], gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, position))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, colour))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, coords))
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(3, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, normal))
	gl.EnableVertexAttribArray(3)

	box.mesh.material.shader = shader_register("../the-carton/shaders/default.vert", "../the-carton/shaders/vertex-colour.frag")
	box.mesh.vertices = mesh
	box.mesh.indices = indices
	return box
}

@(private)
box_draw :: proc(box: ^UI_Atom){
	gl.UseProgram(box.mesh.material.shader)
	gl.BindTexture(gl.TEXTURE_2D, box.mesh.material.texture)
	gl.BindVertexArray(box.mesh.vao)

	model := gl.GetUniformLocation(box.mesh.material.shader, "uni_model")
	view := gl.GetUniformLocation(box.mesh.material.shader, "uni_view")
	projection := gl.GetUniformLocation(box.mesh.material.shader, "uni_projection")

	model_mat := la.identity(matrix[4, 4]f32)
	view_mat := la.identity(matrix[4, 4]f32)
	projection_mat := la.identity(matrix[4, 4]f32)

	gl.UniformMatrix4fv(model, 1, false, raw_data(&model_mat))
	gl.UniformMatrix4fv(view, 1, false, raw_data(&view_mat))
	gl.UniformMatrix4fv(projection, 1, false, raw_data(&projection_mat))

	gl.DrawElements(gl.TRIANGLES, i32(len(box.mesh.indices)), gl.UNSIGNED_INT, nil)
}
