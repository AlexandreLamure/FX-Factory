#version 430

// WARNING : This shader is only used to allow undefined behaviour
// It is a copy of shader `all.glsl'. You sould NEVER code into.

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;

uniform float total_time;
uniform vec2 resolution;

uniform int mesh_id;
uniform int rand;

uniform int FXFrag;

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
/*
    if (bool(FXFrag & TEX_RGB_SPLIT))
    return tex_rgb_split(uv,
    screen_texture,
    total_time,
    rand,
    false);
    else if (bool(FXFrag & DISTORTION))
    return distortion(uv,
    screen_texture,
    total_time,
    rand);
    else if (bool(FXFrag & K7))
    return k7(uv,
    screen_texture,
    total_time, resolution,
    rand);
    else
*/
    return texture(screen_texture, uv);
}

void main()
{
    vec2 uv = interpolated_tex_coords;

    if (bool(FXFrag & TEX_BEFORE))
    output_color *= compute_texel(uv);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */
/*
    if (bool(FXFrag & RECTANGLES))
    output_color = rectangles(uv,
    screen_texture,
    total_time,
    rand,
    output_color, false);
*/
    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */
/*
    if (!bool(FXFrag & TEX_BEFORE))
    output_color *= compute_texel(uv);
*/
}