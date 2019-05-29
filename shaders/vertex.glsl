#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 tex_coords;

out vec4 interpolated_pos;
out vec3 interpolated_normal;
out vec4 interpolated_color;
out vec2 interpolated_tex_coords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;


void main()
{
    interpolated_pos = model * vec4(position, 1);
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix


    gl_Position = projection * view * interpolated_pos;

    interpolated_tex_coords = tex_coords;
}
