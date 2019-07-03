#version 430

#define HUE_NB_LEVELS 20
#define SAT_NB_LEVELS 7
#define VAL_NB_LEVELS 4
float[HUE_NB_LEVELS] hue_levels = float[] (0, 18, 36, 54, 72, 90, 108, 126, 144, 162, 180, 198, 216, 234, 252, 270, 288, 306, 324, 342);
float[SAT_NB_LEVELS] sat_levels = float[] (0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0);
float[VAL_NB_LEVELS] val_levels = float[] (0.0, 0.3, 0.6, 1.0);


vec3 RGBtoHSV(vec3 color)
{
    float r = color.r;
    float g = color.g;
    float b = color.b;

    float minv, maxv, delta;
    vec3 res;

    minv = min(min(r, g), b);
    maxv = max(max(r, g), b);
    // v
    res.z = maxv;

    delta = maxv - minv;

    if(maxv != 0.0)
    // s
    res.y = delta / maxv;
    else // r = g = b = 0
    {
        res.y = 0.0;
        res.x = -1.0;
        return res;
    }

    if(r == maxv)
    res.x = (g - b) / delta;
    else if(g == maxv)
    res.x = 2.0 + (b - r) / delta;
    else
    res.x = 4.0 + (r - g) / delta;

    res.x = res.x * 60.0;
    if(res.x < 0.0)
    res.x = res.x + 360.0;

    return res;
}

vec3 HSVtoRGB(vec3 color)
{
    float h = color.r;
    float s = color.g;
    float v = color.b;

    int i;
    float f, p, q, t;
    vec3 res;

    if(s == 0.0) // achromatic (grey)
    {
        res.x = v;
        res.y = v;
        res.z = v;
        return res;
    }

    h /= 60.0;
    i = int(floor(h));
    f = h - float(i);
    p = v * (1.0 - s);
    q = v * (1.0 - s * f);
    t = v * (1.0 - s * (1.0 - f));

    if (i == 0)
    {
        res.x = v;
        res.y = t;
        res.z = p;
    }
    else if (i == 1)
    {
        res.x = q;
        res.y = v;
        res.z = p;
    }
    else if (i == 2)
    {
        res.x = p;
        res.y = v;
        res.z = t;
    }
    else if (i == 3)
    {
        res.x = p;
        res.y = q;
        res.z = v;
    }
    else if (i == 4)
    {
        res.x = t;
        res.y = p;
        res.z = v;
    }
    else // i == 5
    {
        res.x = v;
        res.y = p;
        res.z = q;
    }
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

    for (int i = 0; i < nb_levels-1; i++)
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
    return 0;
}


vec4 toonify(vec4 color_org)
{
    vec3 vHSV =  RGBtoHSV(color_org.rgb);
    vHSV.x = nearest_level(vHSV.x, 0);
    vHSV.y = nearest_level(vHSV.y, 1);
    vHSV.z = nearest_level(vHSV.z, 2);

    return vec4(HSVtoRGB(vHSV), color_org.a);
}