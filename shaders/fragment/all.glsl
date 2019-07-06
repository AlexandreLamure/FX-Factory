#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

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

#define PI = 3.1415926535;

//#define UNDEFINED
#define COMPUTE_LIGHT
#define TEX_BEFORE
//#define TEX_MOVE
//#define TEX_MOVE_GLITCH
//#define COLORIZE
//#define TEX_RGB_SPLIT
//#define EDGE_ENHANCE
//#define TOONIFY
//#define HORRORIFY


vec4 tex_move_glitch(vec2 uv,
                     sampler2D texture_diffuse1,
                     float total_time,
                     int mesh_id, int rand,
                     int rate);

vec4 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position,
                    vec3 camera_pos,
                    vec4 color_org);

vec4 colorize(vec4 interpolated_pos, vec3 interpolated_normal,
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


vec4 compute_texel(vec2 uv)
{
    vec4 texel;
    #ifdef TEX_MOVE_GLITCH
    texel = tex_move_glitch(uv,
                            texture_diffuse1,
                            total_time,
                            mesh_id, rand,
                            1);
    #endif

    #ifdef TEX_RGB_SPLIT
    texel = tex_rgb_split(uv,
                          texture_diffuse1,
                          total_time,
                          rand);
    #else
    #ifndef TEX_MOVE_GLITCH // FIXME : use returns instead of nested ifdef
    texel = texture(texture_diffuse1, uv);
    #endif
    #endif
    return texel;
}

void main()
{
    #ifndef UNDEFINED
    output_color = vec4(1);
    #endif

    vec2 uv = interpolated_tex_coords;
    #ifdef TEX_MOVE
    uv += 0.1 * total_time;
    #endif

    #ifdef TEX_BEFORE
    output_color *= compute_texel(uv);
    #endif

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */

    #ifdef COLORIZE
    output_color = colorize(interpolated_pos, interpolated_normal,
                            total_time,
                            mesh_id, rand,
                            output_color, 3);
    #endif

    #ifdef EDGE_ENHANCE
    output_color = edge_enhance(uv,
                                texture_diffuse1,
                                total_time,
                                output_color, 0.55, true);
    #endif

    #ifdef COMPUTE_LIGHT
    output_color = compute_lights(interpolated_pos, interpolated_normal,
                                  ambient_light_color,
                                  light1_color, light1_position,
                                  light2_color, light2_position,
                                  camera_pos,
                                  output_color);
    #endif


    #ifdef TOONIFY
    output_color = toonify(output_color);
    output_color = edge_enhance(uv, texture_diffuse1, total_time, output_color, 0.35, false);
    #endif

    #ifdef HORRORIFY
    output_color = horrorify(uv,
                             texture_diffuse1,
                             total_time,
                             mesh_id, rand,
                             output_color, true);
    #endif

    /* ------------------------------------------------------- */
    /* ------------------------------------------------------- */


    #ifndef TEX_BEFORE
    output_color *= compute_texel(uv);
    #endif
}
