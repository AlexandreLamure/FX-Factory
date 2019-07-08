#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;
in mat3 TBN;

out vec4 output_color;

uniform vec3 ambient_light_color;
uniform vec3 light1_color;
uniform vec3 light1_position;
uniform vec3 light2_color;
uniform vec3 light2_position;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_normal1;

uniform float total_time;

uniform vec3 camera_pos;
uniform int mesh_id;
uniform int rand;

uniform int FXFrag;
uniform int factory_level_render;

#define PI = 3.1415926535;

const int UNDEFINED              = 1 << 0; // E
const int COMPUTE_LIGHT          = 1 << 1; // R
const int TEX_BEFORE             = 1 << 2; // T
const int TEX_MOVE               = 1 << 3; // Y
const int TEX_MOVE_GLITCH        = 1 << 4; // U
const int COLORIZE               = 1 << 5; // I
const int TEX_RGB_SPLIT          = 1 << 6; // O
const int EDGE_ENHANCE           = 1 << 7; // P
const int TOONIFY                = 1 << 8; // G
const int HORRORIFY              = 1 << 9; // H
const int PIXELIZE               = 1 << 10; // J


float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec4 tex_move_glitch(vec2 uv,
                     sampler2D texture_diffuse1,
                     float total_time,
                     int mesh_id, int rand,
                     int rate);

vec4 compute_lights(vec4 interpolated_pos, vec3 normal,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position,
                    vec3 camera_pos,
                    vec4 color_org);

vec4 colorize(vec4 interpolated_pos, vec3 normal,
              float total_time,
              int mesh_id, int rand,
              vec4 color_org, int level);

vec4 tex_rgb_split(vec2 uv,
                   sampler2D texture_diffuse1,
                   float total_time,
                   int rand);

vec4 edge_enhance(vec2 uv,
                  sampler2D texture_diffuse1,
                  float total_time,
                  vec4 color_org, float edge_threshold, bool colorize);

vec4 toonify(vec4 color_org);

vec4 horrorify(vec2 uv,
               sampler2D texture_diffuse1,
               float total_time,
               int mesh_id, int rand,
               vec4 color_org, bool colorize);

vec4 pixelize(vec2 uv,
              sampler2D texture_diffuse1,
              float total_time);

vec2 uv;

vec4 compute_texel(vec2 uv, int FX)
{

    if (bool(FX & TEX_MOVE_GLITCH))
        return tex_move_glitch(uv, texture_diffuse1, total_time, mesh_id, rand, 1);
    else if (bool(FX & TEX_RGB_SPLIT))
        return tex_rgb_split(uv, texture_diffuse1, total_time, rand);
    else if (bool(FX & PIXELIZE))
        return pixelize(uv, texture_diffuse1, total_time);
    else
        return texture(texture_diffuse1, uv);
}

vec4 apply_effects(vec4 output_color, int FX)
{
    if (bool(FX & TEX_MOVE))
        uv += 0.1 * total_time;

    if (bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv, FX);

    vec3 normal = interpolated_normal;
    normal = texture(texture_normal1, uv).rgb;
    normal = normalize(normal * 2.0 - 1.0);
    normal = normalize(TBN * normal);
    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    if (bool(FX & COLORIZE))
        output_color = colorize(interpolated_pos, normal, total_time, mesh_id, rand, output_color, 3);

    if (bool(FX & EDGE_ENHANCE))
        output_color = edge_enhance(uv, texture_diffuse1, total_time, output_color, 0.55, true);

    if (bool(FX & COMPUTE_LIGHT))
        output_color = compute_lights(interpolated_pos, normal,
                                      ambient_light_color, light1_color, light1_position, light2_color, light2_position,
                                      camera_pos, output_color);


    if (bool(FX & TOONIFY))
    {
        output_color = toonify(output_color);
        output_color = edge_enhance(uv, texture_diffuse1, total_time, output_color, 0.35, false);
    }

    if (bool(FX & HORRORIFY))
        output_color = horrorify(uv, texture_diffuse1, total_time, mesh_id, rand, output_color, true);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */


    if (!bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv, FX);

    return output_color;
}

void main()
{
    output_color = vec4(1);

    uv = interpolated_tex_coords;



    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    int nb_loop = 1;
    int FX = FXFrag;

    if (factory_level_render != 0)
        nb_loop = 3;

    for (int i = 0; i < nb_loop; ++i)
    {
        if (factory_level_render == 1)
            FX = int(abs(cos(uv.y * i)) * (1 << 10));
        else if (factory_level_render == 2)
            FX = int(abs(cos(uv.x * i)) * (1 << 10));
        else if (factory_level_render == 3)
            FX = int(abs(cos(length(uv - 0.5) * i)) * (1 << 10));
        else if (factory_level_render == 4)
            FX = int(abs(cos(length(camera_pos / 200))) * (1 << 10));
        else if (factory_level_render == 5)
            FX = int(abs(cos(rand * i)) * (1 << 10));

        output_color = apply_effects(output_color, FX);
    }
}