#version 430

//#define BLACK_AND_WHITE  // FIXME: make it a line that goes down the screen
#define LINES_AND_FLICKER
#define BLOTCHES
//#define GRAIN
//#define DESCENT

float randf(vec2 seed);
float randf(float seed);
float jerky_rand(float seed);

float random_line(vec2 uv, float seed)
{
    float a = randf(seed);
    float b = randf(seed + 1) * 0.01;
    float c = randf(seed + 2) - 0.5;
    float mu = randf(seed + 3);

    float l = pow(abs(a * uv.x + b * uv.y + c), 0.125);
    if (mu > 0.2)
        l = 2 - l;

    return mix(0.5, 1.0, l);
}

// Generate some blotches.
float random_blotch(vec2 uv, float seed)
{
    float x = randf(seed);
    float y = randf(seed + 1);
    float s = randf(seed + 2) * 0.01;

    vec2 p = vec2(x, y) - uv;
    p.x *= resolution.x / resolution.y;
    float a = atan(p.y, p.x);
    float v = 0.2;
    float ss = s * s * (sin(6.2831 * a * x) + 100.0);

    if (dot(p, p) > ss)
        v = pow(dot(p, p) - ss, 0.0625);

    return mix(0.3 + 0.2 * (1.0 - (s / 0.02)), 1.0, v);
}

vec4 (vec2 uv)
{
    vec2 uv = interpolated_tex_coords;

    float intensity = interpolated_tex_coords.y * rand;

    // Get some image movement
    vec2 suv = uv + 0.002 * vec2( randf(intensity), randf(intensity + 23.0));

    // Get the image
    vec4 tex_color = texture2D(screen_texture, vec2(suv.x, suv.y));



    #ifdef DESCENT
    // descending line
    float line_pos = 1.0 - (total_time / 10 - floor(total_time / 10));
    line_pos = line_pos * 5 - 4;
    float line_height = 0.01 + uv.x * rand / 10000;
    if (interpolated_tex_coords.y > line_pos - line_height && interpolated_tex_coords.y < line_pos)
    {
        tex_color = texture(screen_texture, interpolated_tex_coords - 0.1 * rand / 1000);
        if (cos(total_time) * sin(total_time) * cos(total_time) < 0)
        {
            float luma_line = 0.2126 * tex_color.r + 0.7152 * tex_color.g + 0.0722 * tex_color.b;
            output_color.rgb = mix(vec3(luma_line), tex_color.rgb, 0.15);
        }
        else
        output_color = tex_color;
    }
    #endif



    #ifdef BLACK_AND_WHITE
    float luma = 0.2126 * tex_color.r + 0.7152 * tex_color.g + 0.0722 * tex_color.b;
    tex_color.rgb = mix(vec3(luma), tex_color.rgb, 0.25);
    #endif

    // Create a total_time-varyting vignetting effect
    float glitch_coef = 10 * (uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y));
    glitch_coef *= mix(0.7, 1.0, randf(intensity + 0.5));

    // Add additive flicker
    glitch_coef += 0.7 + 0.04 * randf(intensity + 8);

    // Add a fixed vignetting (independent of the flicker)
    glitch_coef *= pow(20 * uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y), 0.4);

    // Add some random lines (and some multiplicative flicker. Oh well.)
    #ifdef LINES_AND_FLICKER
    int intensity_laf = int(3.5 * randf(intensity + 7.0));
    for (int i = 0; i < intensity_laf; ++i)
        glitch_coef *= random_line(uv, intensity);
    #endif

    // Add some random blotches.
    #ifdef BLOTCHES
    int intensity_blotch = int(max(5.0 * randf(intensity+18.0) -2.0, 0.0));
    for (int i = 0; i < intensity_blotch; ++i)
        glitch_coef *= random_blotch(uv, intensity);
    #endif

    output_color = vec4(tex_color.rgb * glitch_coef, tex_color.a);

    #ifdef GRAIN
    output_color.xyz *= (0.9 + (randf(uv + float(rand) / 1000)) * 0.45);
    #endif

}