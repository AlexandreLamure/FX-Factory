#version 430

vec4 rgb_split(vec2 uv,
               sampler2D texture_diffuse1,
               float total_time,
               int rand,
               vec4 color_org)
{
    // rgb splitting
    vec2 dir = uv ;
    float d = (0.5 + cos(total_time) / 10) * length(dir) + rand * 0.01;
    normalize(dir);
    vec2 value = d * dir * (cos(total_time) * float(rand == rand % 10));

    vec4 c1 = texture2D(texture_diffuse1, uv - value);
    vec4 c2 = texture2D(texture_diffuse1, uv);
    vec4 c3 = texture2D(texture_diffuse1, uv + value);
    vec4 texel = vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);

    return /*color_org * */texel;
}