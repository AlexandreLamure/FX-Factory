#version 430

vec3 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 camera_pos,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position)
{
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

    return light_color;
}