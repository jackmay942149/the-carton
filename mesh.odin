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

T_Mesh :: struct {
	parts: []T_Mesh_Part,
	total_vertex: uint,
	total_index: uint,
	buffer_size: uint,
	postions: [][3]f64,
	coords: [][2]f64,
	buffer: []u32,
}

T_Mesh_Part :: struct {
	node_ptr: ^fbx.Node,
	mesh_ptr: ^fbx.Mesh,
	vertex_count: uint,
	index_count: uint,
	buffer_size: uint,
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

	mesh_part_count := 0
	for i in 0..<scene.nodes.count {
		if scene.nodes.data[i].mesh != nil {
			mesh_part_count += 1
		}
	}

	mesh_parts := make([]T_Mesh_Part, mesh_part_count)
	offset := 0
	for i in 0..<scene.nodes.count {
		if scene.nodes.data[i].mesh != nil {
			mesh_parts[offset].mesh_ptr = scene.nodes.data[i].mesh
			mesh_parts[offset].node_ptr = scene.nodes.data[i]
			offset += 1
		}
	}

	t_mesh: T_Mesh
	t_mesh.parts = mesh_parts[:]
	for &part in mesh_parts {
		part.vertex_count = part.mesh_ptr.num_vertices
		part.index_count = part.mesh_ptr.num_indices
		part.buffer_size = part.mesh_ptr.num_triangles * 3
		t_mesh.total_index += part.index_count
		t_mesh.total_vertex += part.vertex_count
		t_mesh.buffer_size += part.buffer_size
	}

	positions := make([][3]f64, t_mesh.total_vertex)
	coords := make([][2]f64, t_mesh.total_vertex)
	offset = 0
	for part in mesh_parts {
		for i in 0..<part.vertex_count {
			positions[offset + int(i)] = fbx.transform_position(&part.node_ptr.geometry_to_world, part.mesh_ptr.vertex_position.values.data[i]) 
			coords[offset + int(i)] = part.mesh_ptr.vertex_uv.values.data[i]
		}
		offset += int(part.vertex_count)
	}

	buffer := make([]u32, t_mesh.buffer_size)
	offset = 0
	index_offset := 0
	vertex_offset : u32 = 0
	for part in mesh_parts {
		for i in 0..<part.mesh_ptr.faces.count {
	    face := part.mesh_ptr.faces.data[i]
	    tris := fbx.catch_triangulate_face(nil, &buffer[offset + index_offset], part.index_count, part.mesh_ptr, face)
	    index_offset += 3 * int(tris)
		}
		for i in offset..<offset + int(part.buffer_size) {
			buffer[i] = part.mesh_ptr.vertex_indices.data[buffer[i]] + vertex_offset
		}
		vertex_offset += u32(part.vertex_count)
		offset += int(part.buffer_size)
		index_offset = 0
	}

  vertices := make([]Vertex, t_mesh.total_vertex)
  for i in 0..<len(vertices) {
  	vertices[i].position = {f32(positions[i].x), f32(positions[i].y), f32(positions[i].z)}
  	vertices[i].coords = {f32(coords[i].x), f32(coords[i].y)}
  }
	mesh.vertices = vertices
	mesh.indices = buffer

	ok: bool
	mesh.material.shader, ok = gl.load_shaders_file("../the-carton/shaders/default.vert", "../the-carton/shaders/default.frag")
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
	data := stbi.load("../the-carton/textures/wall.jpg", &width, &height, &channel_count, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		log.error(stbi.failure_reason())
	}

	return mesh
}
