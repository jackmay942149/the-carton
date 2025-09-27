#version 330 core

in vec3 passColour;
in vec2 passCoord;

uniform sampler2D text;

out vec4 FragColor;

void main() {
  FragColor = texture(text, passCoord);
} 
