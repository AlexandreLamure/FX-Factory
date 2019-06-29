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

void main()
{
    vec2 interpolated_tex_coords_glitch = vec2(interpolated_tex_coords.x + 0.1 * total_time,
    interpolated_tex_coords.y + 0.1 * total_time);
    vec2 interpolated_tex_coords_glitch2 = interpolated_tex_coords;
    if (rand == int(cos(total_time)))
    {
        interpolated_tex_coords_glitch2.x += 1;
        interpolated_tex_coords_glitch2.y += total_time;
    }

    // Light Computation
    vec3 normal = normalize(interpolated_normal);

    // diffuse 1
    vec3 light1_dir = normalize(vec3(light1_position - interpolated_pos.xyz));
    float coef = dot(normal, light1_dir);
    coef = clamp(coef, 0, 1);
    vec3 light_color = light1_color * coef;

    // diffuse 2
    vec3 light2_dir = normalize(vec3(light2_position - interpolated_pos.xyz));
    float coef2 = dot(normal, light2_dir);
    coef2 = clamp(coef2, 0, 1);
    light_color += light2_color * coef2;

    // specular 1
    int shininess = 32;
    float spec_strength = 0.7;
    vec3 camera_dir1 = normalize(camera_pos - interpolated_pos.xyz);
    vec3 reflect_dir1 = reflect(-light1_dir, normal);
    float spec1 = pow(max(dot(camera_dir1, reflect_dir1), 0.0), shininess);
    vec3 specular1 = spec_strength * spec1 * light1_color;
    light_color += specular1;

    // specular 2
    vec3 camera_dir2 = normalize(camera_pos - interpolated_pos.xyz);
    vec3 reflect_dir2 = reflect(-light2_dir, normal);
    float spec2 = pow(max(dot(camera_dir2, reflect_dir2), 0.0), shininess);
    vec3 specular2 = spec_strength * spec2 * light2_color;
    light_color += specular2;

    // ambient
    light_color += ambient_light_color;


    vec4 texel1 = texture(texture_diffuse1, interpolated_tex_coords);
    vec4 texel2 = texture(texture_diffuse1, interpolated_tex_coords_glitch);
    vec4 texel3 = texture(texture_diffuse1, interpolated_tex_coords_glitch2);
    vec4 texel = texel2;//mix(texel1, texel3, 0.5);


    output_color = vec4(light_color, 1) * texel;

}
