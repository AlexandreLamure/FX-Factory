#version 430

vec3 tex_rgb_split(vec2 uv,
                   sampler2D light_texture,
                   float total_time,
                   int rand)
{
    // compute decay value
    vec2 dir = uv - vec2(0.5);
    float d = (0.5 + cos(total_time) / 10) * length(dir) + rand * 0.01;
    normalize(dir);
    vec2 value = d * dir * (cos(total_time) * float(rand == rand % 10));

    // compute each channel
    vec4 c1 = texture(light_texture, uv - value);
    vec4 c2 = texture(light_texture, uv);
    vec4 c3 = texture(light_texture, uv + value);
    return vec3(c1.r, c2.g, c3.b);
}