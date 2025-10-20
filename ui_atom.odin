package carton

UI_Atom :: struct {
	draw:     proc(^UI_Atom),
	on_click: proc(^UI_Atom),
	on_hover: proc(^UI_Atom),
	position: [2]f32,
	size:     [2]f32,
	mesh:     Mesh,
}
