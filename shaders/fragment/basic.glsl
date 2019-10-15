#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform DirLight dir_lights[NB_DIR_LIGHTS];
uniform PointLight point_lights[NB_POINT_LIGHTS];

uniform sampler2D texture_ambient1;
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;

uniform vec3 camera_pos;

vec4 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 camera_pos, vec4 color_org,
                    Material material,
                    DirLight dir_lights[NB_DIR_LIGHTS],
                    PointLight point_lights[NB_POINT_LIGHTS]);


void main()
{
    Material material;
    material.ambient = vec3(texture(texture_ambient1, interpolated_tex_coords));
    material.diffuse = vec3(texture(texture_diffuse1, interpolated_tex_coords));
    material.specular = vec3(texture(texture_specular1, interpolated_tex_coords));
    material.shininess = 1; //FIXME


    output_color = compute_lights(interpolated_pos, interpolated_normal,
                                  camera_pos, vec4(1),
                                  material,
                                  dir_lights,
                                  point_lights);
}