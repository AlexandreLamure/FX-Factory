#version 430

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);
float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec3 pixelize(vec2 uv,
              sampler2D light_texture,
              float total_time)
{
    const float rt_w = 200 * snoise(vec2(fract(total_time / 50) * 1.2)) + 1000;
    const float rt_h = 200 * snoise(vec2(fract(total_time / 50) * 1.2)) + 1000;
    const float pixel_w = 15;
    const float pixel_h = 10;

    vec3 tc = vec3(1.0, 0.0, 0.0);
    float dx = pixel_w * (1. / rt_w);
    float dy = pixel_h * (1. / rt_h);
    vec2 coord = vec2(dx * floor(uv.x / dx),
    dy * floor(uv.y / dy));
    tc = texture2D(light_texture, coord).rgb;
    return tc;
}
