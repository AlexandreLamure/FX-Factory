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


    //output_color = vec4(cos(2*total_time) / 2., sin(total_time) / 2., 0.2f, 1);
    vec4 texel1 = texture(texture_diffuse1, interpolated_tex_coords);
    vec4 texel2 = texture(texture_diffuse1, interpolated_tex_coords_glitch);
    vec4 texel3 = texture(texture_diffuse1, interpolated_tex_coords_glitch2);
    vec4 texel = texel1;//mix(texel1, texel3, 0.5);

    vec4 glitch_color = vec4(0);
    if (rand % 11 == rand % 13 && // rate
    int((mesh_id + 10) * fract(total_time)) == int((mesh_id + 10) * sin(total_time)))
    {
        glitch_color = 1.0 * interpolated_pos * cos(total_time);
        glitch_color.g += cos(rand);
        glitch_color.b *= rand;
    }

    vec4 glitch_color2 = vec4(0);
    if (mesh_id % 10 == int(total_time) % 7 &&
        (int(6*cos(interpolated_normal.y + cos(0.1*total_time))) == int((6.1 + 0.05 * cos(total_time))*sin(interpolated_normal.z))))
    {
        glitch_color2 = 1.0 * interpolated_pos * sin(total_time);
        glitch_color2.r *= cos(total_time);
        glitch_color2.b *= fract(total_time);
    }

    vec4 glitch_color3 = vec4(0);
    if (rand % 20 == rand % 18 && // rate
        mesh_id % 15 == rand % 15 && // target mesh
        ((rand % 3 == 0 && int(fract(interpolated_pos.x*rand)) % 8 == int(total_time) % 2) ||
         (rand % 3 == 1 && int(fract(interpolated_pos.y*rand)) % 8 == int(total_time) % 2) ||
         (rand % 3 == 2 && int(fract(interpolated_pos.z*rand)) % 8 == int(total_time) % 2))
        )
    {
        glitch_color3 = 1.0 * interpolated_pos * cos(total_time);
        glitch_color3.r += 1;
        glitch_color3.b *= fract(total_time);
    }



    output_color = vec4(light_color, 1) * texel;
    output_color += glitch_color;
    output_color -= glitch_color2;
    output_color -= glitch_color3;
}
