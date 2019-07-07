#version 430

#define HUE_NB_LEVELS 20
#define SAT_NB_LEVELS 6
#define VAL_NB_LEVELS 4
float[HUE_NB_LEVELS] hue_levels = float[] (0, 18, 36, 54, 72, 90, 108, 112, 148, 162, 180, 198, 216, 234, 252, 270, 288, 306, 324, 360);
float[SAT_NB_LEVELS] sat_levels = float[] (0.0, 0.2, 0.4, 0.6, 0.8, 1.0);
float[VAL_NB_LEVELS] val_levels = float[] (0.0, 0.3, 0.6, 1.0);


vec3 RGBtoHSV(vec3 color)
{
    float r = color.r;
    float g = color.g;
    float b = color.b;

    float min_rgb, max_rgb, delta_rgb;
    vec3 res;

    min_rgb = min(min(r, g), b);
    max_rgb = max(max(r, g), b);
    delta_rgb = max_rgb - min_rgb;

    // h
    if (max_rgb == min_rgb)
        res.x = 0;
    else if (r == max_rgb)
        res.x = 6 + (g - b) / delta_rgb;
    else if (g == max_rgb)
        res.x = 2 + (b - r) / delta_rgb;
    else
        res.x = 4 + (r - g) / delta_rgb;

    res.x *= 60;
    res.x = int(res.x) % 360;
    if (res.x < 0)
        res.x += 360;

    // s
    if (max_rgb != 0.0)
        res.y = 1.0 - min_rgb / max_rgb;
    else
        res.y = 0.0;

    // v
    res.z = max_rgb;

    return res;
}

vec3 HSVtoRGB(vec3 color)
{
    float h = color.r;
    float s = color.g;
    float v = color.b;

    int t;
    float f, l, m, n;
    vec3 res;

    t = int(h / 60) % 6;
    f = h / 60 - t;
    l = v * (1 - s);
    m = v * (1 - f - s);
    n = v * (1 - (1 - f) * s);

    if (t == 0)
        res = vec3(v, n, l);
    else if (t == 1)
        res = vec3(m, v, l);
    else if (t == 2)
        res = vec3(l, v, n);
    else if (t == 3)
        res = vec3(l, m, v);
    else if (t == 4)
        res = vec3(n, l, v);
    else // t == 5
        res = vec3(v, l, m);

    return res;
}

float nearest_level(float color, int mode)
{
    int nb_levels;
    if (mode == 0)
        nb_levels = HUE_NB_LEVELS;
    else if (mode == 1)
        nb_levels = SAT_NB_LEVELS;
    else if (mode == 2)
        nb_levels = VAL_NB_LEVELS;

    for (int i = 0; i < nb_levels; i++)
    {
        if (mode == 0)
        {
            if (color >= hue_levels[i] && color <= hue_levels[i+1])
                return hue_levels[i+1];
        }
        else if (mode == 1)
        {
            if (color >= sat_levels[i] && color <= sat_levels[i+1])
                return sat_levels[i+1];
        }
        else if (mode == 2)
        {
            if (color >= val_levels[i] && color <= val_levels[i+1])
                return val_levels[i+1];
        }
    }
    if (mode == 0)
        return 360;
    else if (mode == 1)
        return 0;
    else
        return 1;
}


vec4 toonify(vec4 color_org)
{
    vec3 hsv =  RGBtoHSV(color_org.rgb);

    hsv.x = nearest_level(hsv.x, 0);
    hsv.y = nearest_level(hsv.y, 1);
    hsv.z = nearest_level(hsv.z, 2);

    vec3 rgb = HSVtoRGB(hsv);
    //rgb.g = mix(rgb.g, color_org.g, 0.7);
    return vec4(rgb, color_org.a);
}