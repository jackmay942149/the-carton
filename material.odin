package carton

Material :: struct {
	shader:  u32,
	texture: u32,
}

material_attach_shader :: proc(material: ^Material, shader_id: Shader) {
	assert(material != nil)
	assert(shader_id != 0)
	material.shader = shader_id
}

material_attach_texture :: proc(material: ^Material, texture_id: Texture) {
	assert(material != nil)
	assert(texture_id != 0)
	material.texture = texture_id
}
