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
uniform int mesh_id;
uniform float total_time;



void main()
{
    interpolated_pos = model * vec4(position, 1);
    /*if (int(mesh_id) % 3 == int(total_time) % 2 &&
        int(interpolated_pos.y) % 10 < 5)
        interpolated_pos.x += 2;*/
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix


    gl_Position = projection * view * interpolated_pos;

    interpolated_tex_coords = tex_coords;
}
