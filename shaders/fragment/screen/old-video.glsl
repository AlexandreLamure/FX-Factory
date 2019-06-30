#version 430

//#define BLACK_AND_WHITE
#define LINES_AND_FLICKER
#define BLOTCHES
#define GRAIN

#define FREQUENCY 15.0

in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D screen_texture;
uniform vec2 resolution;
uniform float total_time;
uniform float delta_time;
uniform int rand;

vec2 uv;

float randf(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float randf(float c){
    return randf(vec2(c,1.0));
}

float randomLine(float seed)
{
    float b = 0.01 * randf(seed);
    float a = randf(seed+1.0);
    float c = randf(seed+2.0) - 0.5;
    float mu = randf(seed+3.0);

    float l = 1.0;

    if ( mu > 0.2)
    l = pow(  abs(a * uv.x + b * uv.y + c ), 1.0/8.0 );
    else
    l = 2.0 - pow( abs(a * uv.x + b * uv.y + c), 1.0/8.0 );

    return mix(0.5, 1.0, l);
}

// Generate some blotches.
float randomBlotch(float seed)
{
    float x = randf(seed);
    float y = randf(seed+1.0);
    float s = 0.01 * randf(seed+2.0);

    vec2 p = vec2(x,y) - uv;
    p.x *= resolution.x / resolution.y;
    float a = atan(p.y,p.x);
    float v = 1.0;
    float ss = s*s * (sin(6.2831*a*x)*0.1 + 1.0);

    if ( dot(p,p) < ss ) v = 0.2;
    else
    v = pow(dot(p,p) - ss, 1.0/16.0);

    return mix(0.3 + 0.2 * (1.0 - (s / 0.02)), 1.0, v);
}

void main()
{
    uv = interpolated_tex_coords;//interpolated_pos.xy / resolution.xy;

    // Set frequency of global effect to 20 variations per second
    float t = interpolated_tex_coords.y * rand;//float(int(total_time * FREQUENCY));

    // Get some image movement
    vec2 suv = uv + 0.002 * vec2( randf(t), randf(t + 23.0));

    // Get the image
    vec3 image = texture2D( screen_texture, vec2(suv.x, suv.y) ).xyz;

    #ifdef BLACK_AND_WHITE
    // Pass it to B/W
    float luma = dot( vec3(0.2126, 0.7152, 0.0722), image );
    vec3 oldImage = luma * vec3(0.7, 0.7, 0.7);
    #else
    vec3 oldImage = image;
    #endif

    // Create a total_time-varyting vignetting effect
    float vI = 16.0 * (uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y));
    vI *= mix( 0.7, 1.0, randf(t + 0.5));

    // Add additive flicker
    vI += 1.0 + 0.4 * randf(t+8.);

    // Add a fixed vignetting (independent of the flicker)
    vI *= pow(16.0 * uv.x * (1.0-uv.x) * uv.y * (1.0-uv.y), 0.4);

    // Add some random lines (and some multiplicative flicker. Oh well.)
    #ifdef LINES_AND_FLICKER
    int l = int(8.0 * randf(t+7.0));

    if ( 0 < l ) vI *= randomLine( t);
    if ( 1 < l ) vI *= randomLine( t);
    if ( 2 < l ) vI *= randomLine( t);
    if ( 3 < l ) vI *= randomLine( t);
    if ( 4 < l ) vI *= randomLine( t);
    if ( 5 < l ) vI *= randomLine( t);
    if ( 6 < l ) vI *= randomLine( t);
    if ( 7 < l ) vI *= randomLine( t);

    #endif

    // Add some random blotches.
    #ifdef BLOTCHES
    int s = int( max(8.0 * randf(t+18.0) -2.0, 0.0 ));

    if ( 0 < s ) vI *= randomBlotch( t);
    if ( 1 < s ) vI *= randomBlotch( t);
    if ( 2 < s ) vI *= randomBlotch( t);
    if ( 3 < s ) vI *= randomBlotch( t);
    if ( 4 < s ) vI *= randomBlotch( t);
    if ( 5 < s ) vI *= randomBlotch( t);

    #endif

    // Show the image modulated by the defects
    output_color.xyz = oldImage * vI;

    // Add some grain (thanks, Jose!)
    #ifdef GRAIN
    output_color.xyz *= (1.0+(randf(uv+t*.01)-.2)*.15);
    #endif
}
