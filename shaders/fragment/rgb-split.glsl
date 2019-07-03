#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform float total_time;
uniform sampler2D texture_diffuse1;

uniform vec3 ambient_light_color;
uniform vec3 light1_color;
uniform vec3 light1_position;
uniform vec3 light2_color;
uniform vec3 light2_position;
uniform vec3 camera_pos;
uniform int mesh_id;
uniform int rand;

vec3 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 camera_pos,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position);




void main()
{
    vec3 light_color = compute_lights(interpolated_pos, interpolated_normal,
                                        camera_pos,
                                        ambient_light_color,
                                        light1_color, light1_position,
                                        light2_color, light2_position);

    // rgb splitting
    vec2 dir = interpolated_tex_coords - vec2( .5 );
    float d = .7 * length(dir) + rand * 0.01;
    normalize(dir);
    vec2 value = d * dir * (cos(total_time) * float(rand == rand % 10));

    vec4 c1 = texture2D(texture_diffuse1, interpolated_tex_coords - value);
    vec4 c2 = texture2D(texture_diffuse1, interpolated_tex_coords);
    vec4 c3 = texture2D(texture_diffuse1, interpolated_tex_coords + value);
    vec4 texel = vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);


    output_color = vec4(light_color, 1) * texel;
}
