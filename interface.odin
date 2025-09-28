package engine

import log "core:log"

init_window :: proc(width, height: int, title: string, api: Graphics_Api, allocator := context.allocator) {
	window_init(width, height, title, api, allocator)
}

should_close_window :: proc() -> bool {
	return window_should_close()
}

update_window :: proc(entity: ^Entity) {
	window_update(entity)
}

destroy_window :: proc() {
	window_destroy()
}

@(require_results)
register_mesh :: proc(path: cstring) -> Mesh {
	return mesh_register(path)
}
