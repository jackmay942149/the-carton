package engine

import log "core:log"
import gl  "vendor:OpenGL"

Shader :: u32

@(private)
shader_register :: proc(vert, frag: string) -> (shader_id: Shader) {
	ok: bool
	shader_id, ok = gl.load_shaders_file(vert, frag)
	if !ok {
		log.error("Failed to load shaders")
	}
	return shader_id
}
