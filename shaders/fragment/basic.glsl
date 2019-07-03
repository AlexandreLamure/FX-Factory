#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D texture_diffuse1;

uniform vec3 ambient_light_color;
uniform vec3 light1_color;
uniform vec3 light1_position;
uniform vec3 light2_color;
uniform vec3 light2_position;
uniform vec3 camera_pos;

vec4 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position,
                    vec3 camera_pos,
                    vec4 color_org);


void main()
{
    output_color = texture(texture_diffuse1, interpolated_tex_coords);

    output_color = compute_lights(interpolated_pos, interpolated_normal,
                                  ambient_light_color,
                                  light1_color, light1_position,
                                  light2_color, light2_position,
                                  camera_pos,
                                  output_color);
}
