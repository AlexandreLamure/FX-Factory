#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform float total_time;
uniform sampler2D texture_diffuse1;

uniform vec3 ambient_light_color;
uniform vec3 diffuse1_light_color;
uniform vec3 diffuse1_light_position;
uniform vec3 diffuse2_light_color;
uniform vec3 diffuse2_light_position;

void main()
{
    // light computation
    vec3 diffuse1_light_dir = vec3(diffuse1_light_position - interpolated_pos.xyz);
    float coef = dot(normalize(interpolated_normal), normalize(diffuse1_light_dir));
    coef = clamp(coef, 0, 1);
    vec3 light_color = diffuse1_light_color * coef;

    vec3 diffuse2_light_dir = vec3(diffuse2_light_position - interpolated_pos.xyz);
    float coef2 = dot(normalize(interpolated_normal), normalize(diffuse2_light_dir));
    coef2 = clamp(coef2, 0, 1);
    light_color += diffuse2_light_color * coef2;

    light_color += ambient_light_color;


    //output_color = vec4(cos(2*total_time) / 2., sin(total_time) / 2., 0.2f, 1);
    vec4 texel = texture(texture_diffuse1, interpolated_tex_coords);
    output_color = vec4(light_color, 1) * texel;
}
