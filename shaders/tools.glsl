#version 430

float triangle(float x)
{
    float tmp = fract(x);
    return max(tmp, 1 - tmp) * 2;
}

vec2 circle(float x)
{
    return vec2(cos(x), sin(x));
}

float randf(vec2 seed)
{
    return fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float randf(float seed)
{
    return randf(vec2(seed,1.0));
}

// returns a float in [0, 1[ that is jerky
float jerky_rand(float seed)
{
    float duration = 10;
    return floor(fract(seed) * duration) / duration;
}