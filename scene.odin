package carton

import os   "core:os"
import log  "core:log"
import glfw "vendor:glfw"
import json "core:encoding/json"

Scene :: struct {
	window:   glfw.WindowHandle,
	camera:   Camera,
	entities: []Entity,
	ui:       UI,
	lights:   []Light,
}

Scene_File :: struct {
	json_data: json.Value,
	entities:  []Scene_File_Entity_Description,
}

Scene_File_Entity_Description :: struct {
	name:     string,
	position: [3]f32,
	scale:    [3]f32,
	mesh:     Scene_File_Mesh_Description,
}

Scene_File_Mesh_Description :: struct {
	name:     string,
	path:     string,
	material: Scene_File_Material_Description,
}

Scene_File_Material_Description :: struct {
	vert: string,
	frag: string,
}

@(private)
scene_load_file :: proc(filepath: string) -> (scene: Scene_File) {
	scene_data, ok := os.read_entire_file_from_filename(filepath)
	assert(ok)
	err: json.Error
	scene.json_data, err = json.parse(scene_data)
	if err != nil {
		log.fatal(err)
		assert(false)
	}

	entity_array := scene.json_data.(json.Object)["entities"].(json.Array)
	scene_entities := make([]Scene_File_Entity_Description, len(entity_array))

	for entity, i in entity_array {
		entity_json := entity.(json.Object)

		scene_entities[i].name = entity_json["name"].(json.String)
		scene_entities[i].position.x = f32(entity_json["position"].(json.Array)[0].(json.Float))
		scene_entities[i].position.y = f32(entity_json["position"].(json.Array)[1].(json.Float))
		scene_entities[i].position.z = f32(entity_json["position"].(json.Array)[2].(json.Float))
		scene_entities[i].scale.x = f32(entity_json["scale"].(json.Array)[0].(json.Float))
		scene_entities[i].scale.y = f32(entity_json["scale"].(json.Array)[1].(json.Float))
		scene_entities[i].scale.z = f32(entity_json["scale"].(json.Array)[2].(json.Float))
		scene_entities[i].mesh.name = entity_json["mesh"].(json.Object)["name"].(json.String)
		scene_entities[i].mesh.path = entity_json["mesh"].(json.Object)["path"].(json.String)
		scene_entities[i].mesh.material.vert = entity_json["mesh"].(json.Object)["material"].(json.Object)["vert"].(json.String)
		scene_entities[i].mesh.material.frag = entity_json["mesh"].(json.Object)["material"].(json.Object)["frag"].(json.String)
	}
	scene.entities = scene_entities[:]
	return scene
}
