package engine

import log  "core:log"
import mem  "core:mem"
import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

Mesh :: struct {
	vertices: []Vertex,
	indices:  []i32,
	vao:      u32,
	vbo:      u32,
	ebo:      u32,
	material: Material,
}

@(private)
mesh_register :: proc() -> (mesh: Mesh) {
	vertices := make([]Vertex, 4)
	vertices[0] =	Vertex{position = {-0.5, -0.5, 0.0}, colour = {1, 0, 0}, coords = {0, 0}}
	vertices[1] =	Vertex{position = { 0.5, -0.5, 0.0}, colour = {0, 1, 0}, coords = {1, 0}}
	vertices[2] =	Vertex{position = { 0.5,  0.5, 0.0}, colour = {0, 0, 1}, coords = {1, 1}}
	vertices[3] =	Vertex{position = {-0.5,  0.5, 0.0}, colour = {1, 1, 1}, coords = {0, 1}}
	mesh.vertices = vertices
	
	indices := make([]i32, 6)
	indices[0] = 0
	indices[1] = 2
	indices[2] = 1
	indices[3] = 0
	indices[4] = 3
	indices[5] = 2
	mesh.indices = indices

	ok: bool
	mesh.material.shader, ok = gl.load_shaders_file("./engine/shaders/default.vert", "./engine/shaders/default.frag")
	if !ok {
		log.error("Failed to load shaders")
	}
	gl.UseProgram(mesh.material.shader)

	gl.GenVertexArrays(1, &mesh.vao)
	gl.BindVertexArray(mesh.vao)

	gl.GenBuffers(1, &mesh.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)

	gl.GenBuffers(1, &mesh.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, colour))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, coords))
	gl.EnableVertexAttribArray(2)

	gl.BufferData(gl.ARRAY_BUFFER, len(mesh.vertices) * size_of(Vertex), raw_data(mesh.vertices), gl.STATIC_DRAW)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(i32), raw_data(mesh.indices), gl.STATIC_DRAW)

	gl.GenTextures(1, &mesh.material.texture)
	gl.BindTexture(gl.TEXTURE_2D, mesh.material.texture)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, channel_count: i32
	data := stbi.load("./engine/textures/wall.jpg", &width, &height, &channel_count, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		log.error(stbi.failure_reason())
	}
	return mesh
}
