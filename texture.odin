package engine

import log  "core:log"
import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

Texture :: u32

@(private = "file")
texture_register_runtime :: proc(path: cstring) -> (texture_id: Texture) {
	gl.GenTextures(1, &texture_id)
	gl.BindTexture(gl.TEXTURE_2D, texture_id)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, channel_count: i32
	data := stbi.load(path, &width, &height, &channel_count, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		log.error(stbi.failure_reason())
	}
	return texture_id
}

@(private = "file")
texture_register_comptime :: proc(file: []u8) -> (texture_id: Texture) {
	gl.GenTextures(1, &texture_id)
	gl.BindTexture(gl.TEXTURE_2D, texture_id)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TextureParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, channel_count: i32
	stbi.set_flip_vertically_on_load(1)
	data := stbi.load_from_memory(raw_data(file), i32(len(file)), &width, &height, &channel_count, 0)
	if data != nil {
		gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
		gl.GenerateMipmap(gl.TEXTURE_2D)
	} else {
		log.error(stbi.failure_reason())
	}
	return texture_id
}

@(private)
texture_register :: proc {
	texture_register_comptime,
	texture_register_runtime,
}
