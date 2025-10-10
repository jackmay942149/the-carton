package engine

Entity :: struct {
	position: [3]f32,
	rotation: f32,
	mesh:     ^Mesh,
	start:    proc(^Entity),
	update:   proc(^Entity),
}
