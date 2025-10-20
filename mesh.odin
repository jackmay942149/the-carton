package carton

import log  "core:log"
import mem  "core:mem"
import gl   "vendor:OpenGL"
import la   "core:math/linalg"
import fbx  "./dependencies/ufbx"

Mesh :: struct {
	vertices: []Vertex,
	indices:  []u32,
	vao:      u32,
	vbo:      u32,
	ebo:      u32,
	material: Material,
	needs_update: bool,
}

Mesh_Loader :: struct {
	parts:        []Mesh_Loader_Part,
	total_vertex: uint,
	total_index:  uint,
	buffer_size:  uint,
	postions:     [][3]f64,
	coords:       [][2]f64,
	buffer:       []u32,
}

Mesh_Loader_Part :: struct {
	node_ptr:     ^fbx.Node,
	mesh_ptr:     ^fbx.Mesh,
	vertex_count: uint,
	index_count:  uint,
	buffer_size:  uint,
}

@(private = "file")
open_scene_from_path :: proc(path: cstring) -> (scene: ^fbx.Scene) {
	opts: fbx.Load_Opts
	opts.target_unit_meters = 0.01
	opts.generate_missing_normals = true
	err: fbx.Error
	scene = fbx.load_file(path, &opts, &err)
	if scene == nil {
		log.fatal(err)
	}
	return scene
}

@(private = "file")
open_scene_from_bytes :: proc(file: []u8) -> (scene: ^fbx.Scene) {
	opts: fbx.Load_Opts
	opts.target_unit_meters = 0.01
	opts.generate_missing_normals = true
	err: fbx.Error
	scene = fbx.load_memory(&file[0], len(file), &opts, &err)
	if scene == nil {
		log.fatal(err)
	}
	return scene
}

@(private)
mesh_register_runtime :: proc(path: cstring) -> (mesh: Mesh) {
	scene := open_scene_from_path(path)
	return process_scene(scene)
}

@(private)
mesh_register_comptime :: proc(file: []u8) -> (mesh: Mesh) {
	scene := open_scene_from_bytes(file)
	return process_scene(scene)
}

@(private)
mesh_register :: proc{
	mesh_register_comptime,
	mesh_register_runtime,
}

@(private = "file")
process_scene :: proc(scene: ^fbx.Scene) -> (mesh: Mesh) {
	mesh_part_count := 0
	for i in 0..<scene.nodes.count {
		if scene.nodes.data[i].mesh != nil {
			mesh_part_count += 1
		}
	}

	mesh_parts := make([]Mesh_Loader_Part, mesh_part_count)
	offset := 0
	for i in 0..<scene.nodes.count {
		if scene.nodes.data[i].mesh != nil {
			mesh_parts[offset].mesh_ptr = scene.nodes.data[i].mesh
			mesh_parts[offset].node_ptr = scene.nodes.data[i]
			offset += 1
		}
	}

	t_mesh: Mesh_Loader
	t_mesh.parts = mesh_parts[:]
	for &part in mesh_parts {
		part.vertex_count = part.mesh_ptr.num_vertices
		part.index_count = part.mesh_ptr.num_indices
		part.buffer_size = part.mesh_ptr.num_triangles * 3
		t_mesh.total_index += part.index_count
		t_mesh.total_vertex += part.vertex_count
		t_mesh.buffer_size += part.buffer_size
	}

	positions := make([][3]f64, t_mesh.total_index)
	coords := make([][2]f64, t_mesh.total_index)
	normals := make([][3]f64, t_mesh.total_index)
	colours := make([][3]f64, t_mesh.total_index)

	offset = 0
	for part in mesh_parts {
		for i in 0..<part.index_count {
			positions[offset + int(i)] = fbx.transform_position(&part.node_ptr.geometry_to_world, part.mesh_ptr.vertex_position.values.data[part.mesh_ptr.vertex_position.indices.data[i]]) 
			coords[offset + int(i)] = part.mesh_ptr.vertex_uv.values.data[part.mesh_ptr.vertex_uv.indices.data[i]]
			normals[offset + int(i)] = part.mesh_ptr.vertex_normal.values.data[part.mesh_ptr.vertex_normal.indices.data[i]]
			colours[offset + int(i)] = {1, 1, 1}
			if positions[offset + int(i)].x < 0.1 && positions[offset + int(i)].x > -0.2 {
				colours[offset + int(i)] = {0, 0, 0}
			}
		}

		offset += int(part.index_count)
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
			buffer[i] = buffer[i] + vertex_offset
		}
		vertex_offset += u32(part.index_count)
		offset += int(part.buffer_size)
		index_offset = 0
	}

  vertices := make([]Vertex, t_mesh.total_index)
  for i in 0..<len(vertices) {
  	vertices[i].position = {f32(positions[i].x), f32(positions[i].y), f32(positions[i].z)}
  	vertices[i].coords = {f32(coords[i].x), f32(coords[i].y)}
  	vertices[i].normal = {f32(normals[i].x), f32(normals[i].y), f32(normals[i].z)}
  	vertices[i].colour = {f32(colours[i].x), f32(colours[i].y), f32(colours[i].z),}
  }
	mesh.vertices = vertices
	mesh.indices = buffer

	gl.GenVertexArrays(1, &mesh.vao)
	gl.BindVertexArray(mesh.vao)

	gl.GenBuffers(1, &mesh.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(mesh.vertices) * size_of(Vertex), &mesh.vertices[0], gl.DYNAMIC_DRAW)

	gl.GenBuffers(1, &mesh.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(i32), &mesh.indices[0], gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, position))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, colour))
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, coords))
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(3, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, normal))
	gl.EnableVertexAttribArray(3)

	return mesh
}
