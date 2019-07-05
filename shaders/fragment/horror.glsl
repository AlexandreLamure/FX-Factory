#version 430

float randf(vec2 seed)
{
    return fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float randf(float seed)
{
    return randf(vec2(seed,1.0));
}

vec4 horrorify(vec2 uv,
               sampler2D texture_diffuse1,
               float total_time,
               int mesh_id, int rand,
               vec4 color_org, bool colorize)
{
    vec3 color;

    float intensity = uv.y * rand;

    // Get some image movement
    vec2 uv_glitch = uv + 0.005 * vec2(randf(intensity), randf(intensity + 23.0));

    // Get the image
    vec3 tex_color = texture(texture_diffuse1, uv_glitch).xyz;

    float luma = 0.2126 * color_org.r + 0.7152 * color_org.g + 0.0722 * color_org.b;
    float coef = colorize ? 0.05 * uv.x * intensity * float(colorize && cos(total_time) < cos(total_time / uv_glitch.y)) : 0.4;
    color = mix(vec3(luma), color_org.rgb, cos(total_time * intensity / 200 * uv_glitch.y) * coef);

    float glitch_coef = 10.0 * (uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y));
    glitch_coef *= mix(1.0, 5.0, randf(intensity + 0.5));

    glitch_coef += 1.0 + 0.4 * randf(intensity + 8);

    glitch_coef *= (1.0 + 0.2 * cos(total_time) * randf(intensity + rand));
    glitch_coef *= (1.0 + 0.2 * cos(uv.x) * randf(uv.y));
    glitch_coef *= (0.5 + 0.1 * cos(rand) * randf(uv.x * intensity));
    glitch_coef *= (0.4 + 1.15 * float(rand) / 300 * fract(randf(length(uv))));

    glitch_coef *= (1.0 + randf(uv + intensity * 0.01) * (cos(total_time * rand / 1000) - 0.8) * 4);

    if (mesh_id % 20 == int(total_time) % 16)
        color_org.a *= cos(total_time) * sin(total_time);

    return vec4(color * glitch_coef, color_org.a);
}