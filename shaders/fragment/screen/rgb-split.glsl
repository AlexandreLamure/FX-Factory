#version 430

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform float total_time;
uniform int rand;

// returns a float in [0, 1[ that is jerky
float jerky_rand(float seed)
{
    float duration = 10;
    return floor(fract(seed) * duration) / duration;
}

float randf(vec2 seed)
{
    return fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float randf(float seed)
{
    return randf(vec2(seed,1.0));
}


// rgb splitting
void main()
{

    bool slow = true;
    vec2 decay;
    if (slow && cos(total_time + rand / 100) < 0.9)
    {
        decay = vec2(0.1 * cos(total_time + 1.2), 0) * jerky_rand(total_time / 10) * jerky_rand(total_time) * jerky_rand(sin(total_time) * randf(floor(interpolated_tex_coords.y *10))) * float(rand != rand % 5);
    }
    else
    {
        vec2 dir = interpolated_tex_coords - vec2( .5 );
        float d = .7 * length(dir) + rand * 0.01;
        normalize(dir);
        float jerk = float(rand == rand % 5);
        float loop = cos(total_time);
        decay = d * dir  * loop * jerk;
    }

    vec4 c1 = texture2D(screen_texture, interpolated_tex_coords - decay);
    vec4 c2 = texture2D(screen_texture, interpolated_tex_coords);
    vec4 c3 = texture2D(screen_texture, interpolated_tex_coords + decay);
    vec4 texel = vec4(c1.r, c2.g, c3.b, c1.a + c2.a + c3.a);


    output_color = texel;
}
