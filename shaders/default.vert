#version 330 core

layout (location = 0) in vec3 inPos;
layout (location = 1) in vec3 inColour;
layout (location = 2) in vec2 inCoord;

out vec3 passColour;
out vec2 passCoord;

void main() {
  passColour = inColour;
  passCoord = inCoord;
  gl_Position = vec4(inPos.x, inPos.y, inPos.z, 1.0);
}
