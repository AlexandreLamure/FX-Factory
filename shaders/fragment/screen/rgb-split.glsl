#version 430

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);

vec4 rgb_split(vec2 uv,
               sampler2D screen_texture,
               float total_time,
               int rand,
               bool slow)
{
    vec2 decay;
    if (slow && cos(total_time + rand / 100) < 0.9)
    {
        decay = vec2(0.1 * cos(total_time + 1.2), 0) * jerky_rand(total_time / 10) * jerky_rand(total_time) * jerky_rand(sin(total_time) * randf(floor(uv.y *10))) * float(rand != rand % 5);
    }
    else
    {
        vec2 dir = uv - vec2(0.5);
        float d = 0.3 * length(dir) + rand * 0.008;
        normalize(dir);
        float jerk = float(rand == rand % 5);
        float loop = cos(total_time);
        decay = d * dir  * loop * jerk;
    }

    vec4 c1 = texture2D(screen_texture, uv - decay);
    vec4 c2 = texture2D(screen_texture, uv);
    vec4 c3 = texture2D(screen_texture, uv + decay);
    return vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);
}
