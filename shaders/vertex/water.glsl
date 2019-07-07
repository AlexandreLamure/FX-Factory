#version 430

vec2 circle(float x);
float snoise(vec2 v);
float snoise(vec3 v);
float snoise(vec4 v);

vec3 water(vec3 position, vec3 normal, float total_time)
{
    normal *= snoise(position.xy * (circle(total_time * 0.006) * 50 - 50) / 2);
    return normal;
}
