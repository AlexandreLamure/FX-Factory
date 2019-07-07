#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;

uniform float total_time;
uniform vec2 resolution;

uniform vec3 camera_pos;
uniform int mesh_id;
uniform int rand;

uniform int FXFrag;
uniform int factory_level_screen;

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
                vec4 color_org);

vec4 k7(vec2 uv,
        sampler2D screen_texture,
        float total_time,
        vec2 resolution,
        int rand);

vec4 compute_texel(vec2 uv, int FX)
{
    if (bool(FX & TEX_RGB_SPLIT))
        return tex_rgb_split(uv, screen_texture, total_time, rand, false);
    else if (bool(FX & DISTORTION))
        return distortion(uv, screen_texture, total_time, rand);
    else if (bool(FX & K7))
        return k7(uv, screen_texture, total_time, resolution, rand);
    else
        return texture(screen_texture, uv);
}

vec4 apply_effects(vec2 uv, vec4 output_color, int FX)
{
    if (bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv, FX);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    if (bool(FX & RECTANGLES))
        output_color = rectangles(uv, screen_texture, total_time, rand, output_color);

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    if (!bool(FX & TEX_BEFORE))
        output_color *= compute_texel(uv, FX);

    return output_color;
}

void main()
{
    output_color = vec4(1);

    vec2 uv = interpolated_tex_coords;

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    int nb_loop = 1;
    int FX = FXFrag;

    if (factory_level_screen != 0)
    nb_loop = 3;

    for (int i = 0; i < nb_loop; ++i)
    {
        if (factory_level_screen == 1)
            FX = int(abs(cos(uv.y * i)) * (1 << 6));
        else if (factory_level_screen == 2)
            FX = int(abs(cos(uv.x * i)) * (1 << 6));
        else if (factory_level_screen == 3)
            FX = int(abs(cos(length(uv - 0.5) * i)) * (1 << 6));
        else if (factory_level_screen == 4)
            FX = int(abs(cos(length(camera_pos / 200))) * (1 << 6));
        else if (factory_level_screen == 5)
            FX = int(abs(cos(rand * i)) * (1 << 6));

        output_color = apply_effects(uv, output_color, FX);
    }
}