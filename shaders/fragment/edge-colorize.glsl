#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform float total_time;
uniform vec2 mouse_pos;
uniform int rand;

#define EDGE_THRESHOLD 0.55
#define PI 3.1415926535

float is_edge(vec2 coords)
{
    vec2 screen_size = textureSize(screen_texture, 0);
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
            vec4 tex_color = texture(screen_texture, coords + vec2(float(i)*dx, float(j)*dy));
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
    vec2 uv = interpolated_tex_coords.xy;

    vec3 tex_color = texture(screen_texture, uv).rgb;

    vec3 edge_color = vec3(0.0, 0.0, 0.0);
    edge_color.r = cos(uv.x * tex_color.r) * sin(total_time);
    edge_color.g = edge_color.r * cos(total_time * uv.y);
    edge_color.r = edge_color.r / edge_color.g * cos(uv.y) * sin(total_time);

    output_color = vec4((is_edge(uv) >= EDGE_THRESHOLD) ? edge_color : tex_color, 1);
}
