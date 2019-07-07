#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 tex_coords;
layout (location = 3) in vec3 tangent;
layout (location = 4) in vec3 bitangent;

out vec4 interpolated_pos;
out vec3 interpolated_normal;
out vec4 interpolated_color;
out vec2 interpolated_tex_coords;
out mat3 TBN;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform int mesh_id;
uniform float total_time;
uniform int rand;

uniform int FXVertex;
uniform int factory_level_render;

const int TEX_TRANSPOSE          = 1 << 0; // 0
const int WATER                  = 1 << 1; // 9

float triangle(float x);
vec2 circle(float x);
float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec3 water(vec3 position, vec3 normal, float total_time);

vec3 tex_transpose(vec3 position, float total_time, int mesh_id, int rand, float glitch_intensity);

void apply_effects(int FX)
{
    if (bool(FXVertex & TEX_TRANSPOSE))
        interpolated_pos.xyz = tex_transpose(interpolated_pos.xyz, total_time, mesh_id, rand, 0.002);
    if (bool(FXVertex & WATER))
        interpolated_normal = water(position, normal, total_time);
}

void main()
{
    interpolated_pos = model * vec4(position, 1);
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix
    interpolated_tex_coords = tex_coords;

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

        apply_effects(FX);
    }

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */


    /*
    vec3 T = normalize(vec3(model * vec4(tangent, 0.0)));
    vec3 B = normalize(vec3(model * vec4(bitangent, 0.0)));
    vec3 N = normalize(vec3(model * vec4(normal, 0.0)));
    T = normalize(T - dot(T, N) * N);
    TBN = mat3(T, B, N);
    */

    gl_Position = projection * view * interpolated_pos;

}