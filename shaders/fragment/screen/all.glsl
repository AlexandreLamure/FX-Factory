#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;

uniform float total_time;
uniform vec2 resolution;

uniform int mesh_id;
uniform int rand;

uniform int FX;

#define PI = 3.1415926535;

//#define RAIN

const int UNDEFINED              = 1 << 0; // W
const int TEX_BEFORE             = 1 << 1; // X
const int TEX_RGB_SPLIT          = 1 << 2; // C
const int RECTANGLES             = 1 << 3; // V
const int DISTORTION             = 1 << 4; // B
const int K7                     = 1 << 5; // N

vec4 tex_rgb_split(vec2 uv,
                   sampler2D screen_texture,
                   float total_time,
                   int rand,
                   bool slow);

vec4 distortion(vec2 uv,
                sampler2D screen_texture,
                float total_time,
                int rand);

vec4 rectangles(vec2 uv,
                sampler2D screen_texture,
                float total_time,
                int rand,
                vec4 color_org, bool colorize);

vec4 k7(vec2 uv,
        sampler2D screen_texture,
        float total_time,
        vec2 resolution,
        int rand);

vec4 compute_texel(vec2 uv)
{
    if (bool(FX & TEX_RGB_SPLIT))
        return tex_rgb_split(uv,
                             screen_texture,
                             total_time,
                             rand,
                             false);
    else if (bool(FX & DISTORTION))
        return distortion(uv,
                          screen_texture,
                          total_time,
                          rand);
    else if (bool(FX & K7))
        return k7(uv,
                  screen_texture,
                  total_time, resolution,
                  rand);
    else
        return texture(screen_texture, uv);
}

void main()
{
    output_color = vec4(1);

    vec2 uv = interpolated_tex_coords;

    if (bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    if (bool(FX & RECTANGLES))
        output_color = rectangles(uv,
                                  screen_texture,
                                  total_time,
                                  rand,
                                  output_color, false);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    if (!bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv);
}