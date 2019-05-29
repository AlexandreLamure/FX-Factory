#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 tex_coords;

out vec4 interpolated_color;
out vec2 interpolated_tex_coords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 normal_mat;

uniform vec3 ambient_light_color;
uniform vec3 diffuse_light_color;
uniform vec3 diffuse_light_position;


void main()
{
    vec4 new_pos = model * vec4(position, 1);
    vec4 new_normal = normal_mat * vec4(normal, 1);

    // light computation
    vec3 diffuse_light_dir = vec3(diffuse_light_position - new_pos.xyz);
	float coef = dot(normalize(new_normal.xyz), normalize(diffuse_light_dir));
	coef = clamp(coef, 0, 1);
	interpolated_color = vec4(diffuse_light_color * coef + ambient_light_color, 1.);

    gl_Position = projection * view * new_pos;

    interpolated_tex_coords = tex_coords;
}
