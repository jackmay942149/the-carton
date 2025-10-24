package carton

import label "./the-label"

init_window :: proc(width, height: int, title: string, api: Graphics_Api, allocator := context.allocator) {
	window_init(width, height, title, api, allocator)
}

should_close_window :: proc() -> bool {
	return window_should_close()
}

update_window :: proc(scene: ^Scene) {
	window_update(scene)
}

destroy_window :: proc() {
	window_destroy()
}

@(require_results)
register_mesh_cstring :: proc(path: cstring) -> Mesh {
	return mesh_register(path)
}
@(require_results)
register_mesh_string :: proc(path: string) -> Mesh {
	return mesh_register(path)
}
@(require_results)
register_mesh_bytes :: proc(file: []u8) -> Mesh {
	return mesh_register(file)
}
@(require_results)
register_mesh :: proc {
	register_mesh_bytes,
	register_mesh_cstring,
	register_mesh_string,
}

@(require_results)
register_shader :: proc(vert, frag: string) -> Shader {
	return shader_register(vert, frag)
}

@(require_results)
register_texture_cstring :: proc(path: cstring) -> Texture {
	return texture_register(path)
}
@(require_results)
register_texture_bytes :: proc(file: []u8) -> Texture {
	return texture_register(file)
}
@(require_results)
register_texture :: proc {
	register_texture_bytes,
	register_texture_cstring,
}

attach_shader_to_material :: proc(material: ^Material, shader_id: Shader) {
	material_attach_shader(material, shader_id)
}

attach_texture_to_material :: proc(material: ^Material, texture_id: Texture) {
	material_attach_texture(material, texture_id)
}

// Input
is_key_down :: proc(key: Key) -> bool {
	return input_is_key_down(key)
}

is_mouse_down :: proc(mb: Mouse_Button) -> bool {
	return is_mouse_down(mb)
}

get_mouse_position :: proc() -> (x, y: f64) {
	return input_mouse_position()
}

get_mouse_delta :: proc() -> (x, y: f64) {
	return input_mouse_delta()
}

get_scroll_input :: proc() -> (x, y: f32) {
	return input_get_scroll()
}

// the-label bindings
update_label :: proc(path_label, path_key: string) {label.update_label(path_label, path_key)}
load_label :: proc(path: string) -> label.KV_Label {return label.load_label(path)}
get_label_value_string :: proc(key: string, label_to_check: label.KV_Label) -> (value: string, found: bool) {return label.get_value_string(key, label_to_check)}
get_label_value_int :: proc(key: string, label_to_check: label.KV_Label) -> (value: int, found: bool) {return label.get_value_int(key, label_to_check)}
get_label_value_f64 :: proc(key: string, label_to_check: label.KV_Label) -> (value: f64, found: bool) {return label.get_value_f64(key, label_to_check)}
