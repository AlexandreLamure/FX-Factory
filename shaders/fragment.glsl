#version 430

in vec4 interpolated_color;
in vec2 interpolated_tex_coords;
in vec4 interpolated_pos;
in vec4 interpolated_normal;

out vec4 output_color;

uniform float total_time;
uniform sampler2D texture_diffuse1;

uniform vec3 ambient_light_color;
uniform vec3 diffuse_light_color;
uniform vec3 diffuse_light_position;

void main()
{
    // light computation
    vec3 diffuse_light_dir = vec3(diffuse_light_position - interpolated_pos.xyz);
    float coef = dot(normalize(interpolated_normal.xyz), normalize(diffuse_light_dir));
    coef = clamp(coef, 0, 1);
    vec4 light_color = vec4(diffuse_light_color * coef + ambient_light_color, 1.);


    //output_color = vec4(cos(2*total_time) / 2., sin(total_time) / 2., 0.2f, 1);
    vec4 texel = texture(texture_diffuse1, interpolated_tex_coords);
    output_color = light_color * texel;
}
