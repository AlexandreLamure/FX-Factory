#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform float total_time;
uniform vec2 mouse_pos;
uniform int rand;

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);

void main()
{
    bool colorize = true;
    vec4 texel = texture2D(screen_texture, interpolated_tex_coords);

    float height = jerky_rand(total_time / 17) * 0.5;
    float width = jerky_rand(cos(total_time / 18)) * 0.5;
    if (int(jerky_rand(sin(total_time/9.6 + 0.2)) * 10) == int(jerky_rand(total_time/8.8) * 10))
    {
        vec2 start = vec2(jerky_rand(total_time / 12) - 0.25, jerky_rand(total_time * 3 / 14) + 0.25);
        if (interpolated_tex_coords.x > start.x && interpolated_tex_coords.x < start.x + width
            && interpolated_tex_coords.y > start.y - height && interpolated_tex_coords.y < start.y)
        {
            if (colorize)
                texel = vec4(fract(interpolated_tex_coords.x + rand / 8000), cos(total_time + rand / 1000), cos(total_time * 2) * sin(length(interpolated_tex_coords)), 1);
            else
                texel = vec4(0, 0, 0, 1);
        }
    }

    output_color = texel;
}