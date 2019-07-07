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
uniform int rand;

uniform int FXVertex;

const int TEX_TRANSPOSE          = 1 << 0; // 0

vec3 tex_transpose(vec3 position, float total_time, int mesh_id, int rand, float glitch_intensity);

void main()
{
    vec3 pos = position;
    if (bool(FXVertex & TEX_TRANSPOSE))
    {
        pos = tex_transpose(position, total_time, mesh_id, rand, 0.002);
    }

    interpolated_pos = model * vec4(pos, 1);
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix


    gl_Position = projection * view * interpolated_pos;

    interpolated_tex_coords = tex_coords;
}