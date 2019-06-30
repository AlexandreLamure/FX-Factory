#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;

void main()
{
    output_color = texture(screen_texture, interpolated_tex_coords);
}