package engine

import log "core:log"
import gl  "vendor:OpenGL"
import glfw "vendor:glfw"


@(private)
opengl_init :: proc() {
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
}

@(private)
opengl_update :: proc(mesh: ^Mesh) {
	gl.UseProgram(mesh.shader)
	gl.BindTexture(gl.TEXTURE_2D, mesh.texture)
	gl.BindVertexArray(mesh.vao)
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
}
