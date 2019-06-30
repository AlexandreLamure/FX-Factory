#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 tex_coords;

out vec2 interpolated_tex_coords;

void main()
{
    gl_Position = vec4(position.x, position.y, 0.0, 1.0);
    interpolated_tex_coords = tex_coords;
}