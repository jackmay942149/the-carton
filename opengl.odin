package engine

import log "core:log"
import gl  "vendor:OpenGL"
import glfw "vendor:glfw"

vao, shader: u32

@(private)
opengl_init :: proc() {

	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
	vertices := [?]f32 {
		-0.5, -0.5, 0.0,
		 0.5, -0.5, 0.0,
		 0.0,  0.5, 0.0,
	}

	ok: bool
	shader, ok = gl.load_shaders_file("./engine/shaders/default.vert", "./engine/shaders/default.frag")
	if !ok {
		log.error("Failed to load shaders")
	}
	gl.UseProgram(shader)

	vbo: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)


}

@(private)
opengl_update :: proc() {
	gl.UseProgram(shader)
	gl.BindVertexArray(vao)
	gl.DrawArrays(gl.TRIANGLES, 0, 3)
}
