#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform float total_time;
uniform vec2 mouse_pos;
uniform int rand;


void main()
{
    vec2 dir = interpolated_tex_coords - vec2(.5);
    float d = .7 * length(dir) * total_time / 10;
    normalize(dir);
    vec2 value = d * dir;
    vec2 glitch_tex_coords = vec2(interpolated_tex_coords.x + sin(interpolated_tex_coords.x) * d,
                                  interpolated_tex_coords.y + sin(interpolated_tex_coords.x) * d);
    vec4 texel = texture2D(screen_texture, glitch_tex_coords);

    output_color = texel;
}
