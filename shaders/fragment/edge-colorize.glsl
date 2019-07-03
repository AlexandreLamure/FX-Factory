#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D texture_diffuse1;
uniform float total_time;

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



#define EDGE_THRESHOLD 0.55
#define PI 3.1415926535

float is_edge(vec2 coords)
{
    vec2 screen_size = textureSize(texture_diffuse1, 0);
    float dx = 1.0 / float(screen_size.x);
    float dy = 1.0 / float(screen_size.y);
    float kernel[9] = float[](0, 0, 0, 0, 0, 0, 0, 0, 0);
    int k = -1;
    float delta;

    // read neighboring pixel intensities
    for (int i = -1; i < 2; i++)
    {
        for(int j = -1; j < 2; j++)
        {
            k++;
            vec4 tex_color = texture(texture_diffuse1, coords + vec2(float(i)*dx, float(j)*dy));
            kernel[k] = (tex_color.r + tex_color.g + tex_color.b) / 3.;
        }
    }

    // average color differences around neighboring pixels
    delta = (abs(kernel[1]-kernel[7])
    + abs(kernel[5]-kernel[3])
    + abs(kernel[0]-kernel[8])
    + abs(kernel[2]-kernel[6])
    ) / 4.;

    return clamp(5.0 * delta, 0.0, 1.0);
}

void main()
{
    vec3 light_color = compute_lights(interpolated_pos, interpolated_normal,
                                        camera_pos,
                                        ambient_light_color,
                                        light1_color, light1_position,
                                        light2_color, light2_position);
    vec2 uv = interpolated_tex_coords.xy;

    vec3 tex_color = texture(texture_diffuse1, uv).rgb;

    vec3 edge_color = vec3(0.0, 0.0, 0.0);
    edge_color.r = cos(uv.x * tex_color.r) * sin(total_time);
    edge_color.g = edge_color.r * cos(total_time * uv.y);
    edge_color.r = edge_color.r / edge_color.g * cos(uv.y) * sin(total_time);

    output_color = vec4(light_color * ((is_edge(uv) >= EDGE_THRESHOLD) ? edge_color : tex_color), 1);
}