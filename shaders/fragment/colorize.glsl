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


    vec4 texel = texture(texture_diffuse1, interpolated_tex_coords);

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
