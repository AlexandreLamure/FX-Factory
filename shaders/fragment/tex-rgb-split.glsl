#version 430

vec4 tex_rgb_split(vec2 uv,
                   sampler2D texture_diffuse1,
                   float total_time,
                   int rand)
{
    // compute decay value
    vec2 dir = uv - vec2(0.5);
    float d = (0.5 + cos(total_time) / 10) * length(dir) + rand * 0.01;
    normalize(dir);
    vec2 value = d * dir * (cos(total_time) * float(rand == rand % 10));

    // compute each channel
    vec4 c1 = texture(texture_diffuse1, uv - value);
    vec4 c2 = texture(texture_diffuse1, uv);
    vec4 c3 = texture(texture_diffuse1, uv + value);
    vec4 texel = vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);

    return texel;
}