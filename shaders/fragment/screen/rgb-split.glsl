#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform float total_time;
uniform int rand;

void main()
{
    // rgb splitting
    vec2 dir = interpolated_tex_coords - vec2( .5 );
    float d = .7 * length(dir) + rand * 0.01;
    normalize(dir);
    vec2 value = d * dir * (cos(total_time) * float(rand == rand % 5));

    vec4 c1 = texture2D(screen_texture, interpolated_tex_coords - value);
    vec4 c2 = texture2D(screen_texture, interpolated_tex_coords);
    vec4 c3 = texture2D(screen_texture, interpolated_tex_coords + value);
    vec4 texel = vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);


    output_color = texel;
}
