#version 430

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);
float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec4 rain(vec2 uv,
          sampler2D screen_texture,
          float total_time,
          int rand)
{
    vec2 glitch_tex_coords = uv;
    if (randf(uv.x) < 0.5)
        glitch_tex_coords.y += fract(total_time / 20) + randf(uv.x);
    vec4 texel = texture2D(screen_texture, glitch_tex_coords);

    return texel;
}
