#version 430

#define EDGE_THRESHOLD 0.55

float is_edge(vec2 uv, sampler2D texture_diffuse1,
              float total_time)
{
    vec2 tex_size = textureSize(texture_diffuse1, 0);
    float dx = 1.0 / float(tex_size.x*4) * cos(total_time / 2) * 5;
    float dy = 1.0 / float(tex_size.y*4) * sin(total_time / 2) * 5;
    float kernel[9] = float[](0, 0, 0, 0, 0, 0, 0, 0, 0);
    int k = -1;
    float delta;

    // read neighboring pixel intensities
    for (int y = -1; y < 2; y++)
    {
        for(int x = -1; x < 2; x++)
        {
            k++;
            vec4 tex_color = texture(texture_diffuse1, uv + vec2(float(x)*dx, float(y)*dy));
            kernel[k] = (tex_color.r + tex_color.g + tex_color.b) / 3.;
        }
    }

    // average color of opposite neighbors difference
    delta = (abs(kernel[0]-kernel[8])
             + abs(kernel[3]-kernel[5])
             + abs(kernel[6]-kernel[2])
             + abs(kernel[7]-kernel[1])
             ) / 4.;

    return clamp(5.0 * delta, 0.0, 1.0);
}

vec4 edge_enhance(vec2 uv,
                  sampler2D texture_diffuse1,
                  float total_time,
                  vec4 color_org, float edge_threshold, bool colorize)
{
    vec3 edge_color = vec3(0.0, 0.0, 0.0);
    if (colorize)
    {
        edge_color.r = cos(uv.x * color_org.r) * sin(total_time);
        edge_color.g = edge_color.r * cos(total_time * uv.y);
        edge_color.r = edge_color.r / edge_color.g * cos(uv.y) * sin(total_time);
    }
    if ((is_edge(uv, texture_diffuse1, total_time) >= edge_threshold))
        return vec4(edge_color, color_org.a);
    else
        return color_org;
}