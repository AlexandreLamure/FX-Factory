#version 430

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);
float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec4 tex_rgb_split(vec2 uv,
                   sampler2D screen_texture,
                   float total_time,
                   vec2 resolution,
                   int rand,
                   bool slow)
{
    vec2 decay;
    if (slow && cos(total_time + rand / 100) < 0.9)
    {
        const float interval = cos(total_time / 2);
        float strength = smoothstep(interval * 0.5, interval, interval - mod(total_time, interval));
        float y = uv.y * 10;

        decay = vec2(snoise(vec3(0.0, y, total_time * .1)) * (2.0 + strength * 3.0), 0);

        decay.x *= (
            snoise(vec3(0.0, y, total_time * 400.0)) * (2.0 + strength * 3.0)
            * snoise(vec3(0.0, y, total_time * 200.0)) * (1.0 + strength * 4.0)
            + step(0.9995, sin(y + total_time * 1.6)) * 12.0
            + step(0.9999, sin(y + total_time * 2.0)) * -18.0
            ) / resolution.x;
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
