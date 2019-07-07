#version 430

vec4 distortion(vec2 uv,
                sampler2D screen_texture,
                float total_time,
                int rand)
{
    vec2 dir = uv - vec2(.5);
    float d = .7 * length(dir) * total_time / 10;
    normalize(dir);
    vec2 value = d * dir;
    vec2 glitch_uv = vec2(uv.x + sin(uv.x) * d,
                          uv.y + sin(uv.x) * d);

    glitch_uv *= 1.5 * total_time * uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y);

    return texture2D(screen_texture, glitch_uv);
}
