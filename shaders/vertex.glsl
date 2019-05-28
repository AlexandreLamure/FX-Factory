#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 tex_coords;

out vec4 interpolated_color;
out vec2 interpolated_tex_coords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
// temporary
uniform mat4 m;


void main()
{
    gl_Position = /*projection * view * model * */m * vec4(position, 1);
    interpolated_color = vec4(1);
}
