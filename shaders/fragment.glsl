#version 430

in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform float total_time;
uniform sampler2D texture_diffuse1;

void main()
{
    //output_color = vec4(cos(2*total_time) / 2., sin(total_time) / 2., 0.2f, 1);
    output_color = texture(texture_diffuse1, interpolated_tex_coords);
}
