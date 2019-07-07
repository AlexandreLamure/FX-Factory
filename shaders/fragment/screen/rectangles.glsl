#version 430

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);

vec4 rectangles(vec2 uv,
                sampler2D screen_texture,
                float total_time,
                int rand,
                vec4 color_org)
{
    vec4 output_color;
    float height = jerky_rand(sin(total_time / 17)) * 0.5;
    float width = jerky_rand(cos(total_time / 18)) * 0.5;
    if (int(jerky_rand(sin(total_time/9.6 + 0.2)) * 10) == int(jerky_rand(total_time/8.8) * 10))
    {
        vec2 start = vec2(jerky_rand(total_time / 12) - 0.25, jerky_rand(total_time * 3 / 14) + 0.25);
        if (uv.x > start.x && uv.x < start.x + width
            && uv.y > start.y - height && uv.y < start.y)
        {
            float effect = jerky_rand(cos(total_time / 1.4));
            if (effect < 0.2)
                return vec4(0, 0, 0, 1);
            else if (effect < 0.23)
                return vec4(1, 0, 0, 1);
            else if (effect < 0.26)
                return vec4(0, 1, 0, 1);
            else if (effect < 0.3)
                return vec4(0, 0, 1, 1);
            else
            {
                vec2 copy_start = vec2(jerky_rand(total_time / 10) - 0.25, jerky_rand(total_time * 2.8 / 13) + 0.25);
                return texture(screen_texture, vec2(copy_start.x + uv.x - start.x, copy_start.y + uv.y - start.y));
            }
        }
    }
    return color_org;
}