#version 430

#define BLACK_AND_WHITE // FIXME: make it a line that goes down the screen
//#define LINES_AND_FLICKER
//#define BLOTCHES

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D texture_diffuse1;
uniform vec2 resolution;
uniform float total_time;
uniform float delta_time;

uniform vec3 ambient_light_color;
uniform vec3 light1_color;
uniform vec3 light1_position;
uniform vec3 light2_color;
uniform vec3 light2_position;
uniform vec3 camera_pos;
uniform int mesh_id;
uniform int rand;



float randf(vec2 seed)
{
    return fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float randf(float seed)
{
    return randf(vec2(seed,1.0));
}

void main()
{
    vec2 uv = interpolated_tex_coords;

    float intensity = uv.y * rand;

    // Get some image movement
    vec2 uv_glitch = uv + 0.005 * vec2(randf(intensity), randf(intensity + 23.0));

    // Get the image
    vec3 tex_color = texture(texture_diffuse1, uv_glitch).xyz;

    float luma = 0.2126 * tex_color.r + 0.7152 * tex_color.g + 0.0722 * tex_color.b;
    bool colorize = true;
    float coef = colorize ? uv.x * intensity * float(colorize && cos(total_time) < cos(total_time / uv_glitch.y * mesh_id)) : 0.4;
    tex_color = mix(vec3(luma), tex_color, cos(total_time * intensity / 200 * uv_glitch.y) * coef);

    float vI = 10.0 * (uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y));
    vI *= mix(1.0, 5.0, randf(intensity + 0.5));

    vI += 1.0 + 0.4 * randf(intensity + 8);

    vI *= (1.0 + 0.2 * cos(total_time) * randf(intensity + rand));
    vI *= (1.0 + 0.2 * cos(uv.x) * randf(uv.y));
    vI *= (0.5 + 0.1 * cos(rand) * randf(uv.x * intensity));
    vI *= (0.4 + 1.15 * float(rand) / 300 * fract(randf(length(uv))));

    vI *= (1.0 + randf(uv + intensity * 0.01) / 2);

    output_color.xyz = tex_color * vI;
}