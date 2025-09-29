package engine

import log  "core:log"
import mem  "core:mem"
import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"
import la   "core:math/linalg"
import fbx  "./dependencies/ufbx"

Mesh :: struct {
	vertices: []Vertex,
	indices:  []u32,
	vao:      u32,
	vbo:      u32,
	ebo:      u32,
	material: Material,
}

@(private)
mesh_register :: proc(path: cstring) -> (mesh: Mesh) {
	opts: fbx.Load_Opts
	opts.target_unit_meters = 0.01
	err: fbx.Error
	scene := fbx.load_file(path, &opts, &err)
	if scene == nil {
		log.fatal(err)
	}

	index_count: uint = 0
	vertex_count: uint = 0
	for i in 0..<scene.nodes.count {
		node := scene.nodes.data[i]
		log.info(scene.nodes.data[i].element.name)
		if node.mesh != nil {
			index_count += node.mesh.num_indices
			vertex_count += node.mesh.num_indices
		}
	}
	log.info(index_count, vertex_count)
  indices := make([]u32, 100000)
  vertices := make([]Vertex, vertex_count)

  index_offset: u32 = 0
  vertex_offset: u32 = 0
	fbx_mesh: ^fbx.Mesh
	for i in 0..<scene.nodes.count {
		node := scene.nodes.data[i]
		if node.is_root || node.mesh == nil {continue}
		fbx_mesh = node.mesh
		log.info(node.element.name)

		index_count_part: u32 = 3 * u32(fbx_mesh.num_triangles)
	  for i in 0 ..< fbx_mesh.faces.count {
	    face := fbx_mesh.faces.data[i]
	    tris := fbx.catch_triangulate_face(nil, &indices[index_offset], uint(index_count_part), fbx_mesh, face)
	    index_offset += 3 * tris
	  }

	  vertex_count_part: u32 = u32(fbx_mesh.num_indices)
	  for i in 0..< vertex_count_part {
	    pos := fbx_mesh.vertex_position.values.data[fbx_mesh.vertex_position.indices.data[i]]
	    pos *= node.local_transform.scale
	    pos += node.local_transform.translation
	    uv := fbx_mesh.vertex_uv.values.data[fbx_mesh.vertex_uv.indices.data[i]]
	    vertices[u32(i)+vertex_offset].position = {f32(pos.x), f32(pos.y), f32(pos.z)}
	    vertices[u32(i)+vertex_offset].colour = {0, 0, 0}
	    vertices[u32(i)+vertex_offset].coords = {f32(uv.x), f32(uv.y)}
	  }
	  vertex_offset += vertex_count_part
	  index_offset += index_count_part
	}
  fbx.free_scene(scene)

	mesh.vertices = vertices
	mesh.indices = indices

	ok: bool
	mesh.material.shader, ok = gl.load_shaders_file("../engine/shaders/default.vert", "../engine/shaders/default.frag")
	if !ok {
		log.error("Failed to load shaders")
	}
	gl.UseProgram(mesh.material.shader)

	gl.GenVertexArrays(1, &mesh.vao)
	gl.BindVertexArray(mesh.vao)

	gl.GenBuffers(1, &mesh.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(mesh.vertices) * size_of(Vertex), &mesh.vertices[0], gl.STATIC_DRAW)

	gl.GenBuffers(1, &mesh.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(i32), &mesh.indices[0], gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, position))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, colour))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, coords))
	gl.EnableVertexAttribArray(2)


	gl.GenTextures(1, &mesh.material.texture)
	gl.BindTexture(gl.TEXTURE_2D, mesh.material.texture)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, channel_count: i32
	data := stbi.load("../engine/textures/wall.jpg", &width, &height, &channel_count, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		log.error(stbi.failure_reason())
	}

	return mesh
}
