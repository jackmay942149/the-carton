package carton

Entity :: struct {
	id:       int,
	position: [3]f32,
	rotation: f32,
	scale:    [3]f32,
	mesh:     ^Mesh,
	start:    proc(^Entity),
	update:   proc(^Entity),
}
