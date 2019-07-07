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
uniform int factory_level_render;

const int TEX_TRANSPOSE          = 1 << 0; // 0

vec3 tex_transpose(vec3 position, float total_time, int mesh_id, int rand, float glitch_intensity);

vec3 apply_effects(vec2 uv, vec3 pos, int FX)
{
    if (bool(FXVertex & TEX_TRANSPOSE))
    {
        pos = tex_transpose(pos, total_time, mesh_id, rand, 0.002);
    }
    return pos;
}

void main()
{
    vec3 pos = position;

    int nb_loop = 1;
    int FX = FXVertex;

    if (factory_level_render != 0)
        nb_loop = 3;

    for (int i = 0; i < nb_loop; ++i)
    {
        if (factory_level_render == 1)
            FX = int(abs(cos(tex_coords.y * i)) * (1 << 1));
        else if (factory_level_render == 2)
            FX = int(abs(cos(tex_coords.x * i)) * (1 << 1));
        else if (factory_level_render == 3)
            FX = int(abs(cos(length(tex_coords - 0.5) * i)) * (1 << 1));
        else if (factory_level_render == 4)
            FX = int(abs(cos(length(position / 200))) * (1 << 1));
        else if (factory_level_render == 5)
            FX = int(abs(cos(rand * i)) * (1 << 1));

        pos = apply_effects(tex_coords, pos, FX);
    }

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    interpolated_pos = model * vec4(pos, 1);
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix


    gl_Position = projection * view * interpolated_pos;

    interpolated_tex_coords = tex_coords;
}