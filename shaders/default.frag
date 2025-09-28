#version 330 core

in vec3 pass_colour;
in vec2 pass_coord;

uniform sampler2D uni_texture;

out vec4 out_colour;

void main() {
  out_colour = texture(uni_texture, pass_coord);
} 
