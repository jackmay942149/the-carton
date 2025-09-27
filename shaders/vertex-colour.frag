#version 330 core

in vec3 passColour;

out vec4 FragColor;

void main() {
  FragColor = vec4(passColour, 1.0f);
} 
