#version 430

in vec4 interpolated_pos;
in vec3 interpolated_normal;
in vec4 interpolated_color;
in vec2 interpolated_tex_coords;

out vec4 output_color;

uniform sampler2D texture_diffuse1;
uniform vec3 ambient_light_color;
uniform vec3 light1_color;
uniform vec3 light1_position;
uniform vec3 light2_color;
uniform vec3 light2_position;
uniform vec3 camera_pos;


vec3 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 camera_pos,
                    vec3 ambient_light_color,
                    vec3 light1_color, vec3 light1_position,
                    vec3 light2_color, vec3 light2_position);

#define PI = 3.1415926535;

#define HueLevCount 20
#define SatLevCount 7
#define ValLevCount 4
float[HueLevCount] HueLevels = float[] (0, 18, 36, 54, 72, 90, 108, 126, 144, 162, 180, 198, 216, 234, 252, 270, 288, 306, 324, 342);
float[SatLevCount] SatLevels = float[] (0.0,0.15,0.3,0.45,0.6,0.8,1.0);
float[ValLevCount] ValLevels = float[] (0.0,0.3,0.6,1.0);


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

float nearest_level(float col, int mode)
{
    int levCount;
    if (mode==0) levCount = HueLevCount;
    if (mode==1) levCount = SatLevCount;
    if (mode==2) levCount = ValLevCount;

    for (int i = 0; i < levCount-1; i++)
    {
        if (mode==0)
        {
            if (col >= HueLevels[i] && col <= HueLevels[i+1])
            return HueLevels[i+1];
        }
        else if (mode==1)
        {
            if (col >= SatLevels[i] && col <= SatLevels[i+1])
            return SatLevels[i+1];
        }
        else if (mode==2)
        {
            if (col >= ValLevels[i] && col <= ValLevels[i+1])
            return ValLevels[i+1];
        }
    }
    return 0;
}


void main()
{
    vec3 light_color = compute_lights(interpolated_pos, interpolated_normal,
                                      camera_pos,
                                      ambient_light_color,
                                      light1_color, light1_position,
                                      light2_color, light2_position);
    vec2 uv = interpolated_tex_coords.xy;

    vec3 color_org = texture(texture_diffuse1, uv).rgb * light_color;
    vec3 vHSV =  RGBtoHSV(color_org);
    vHSV.x = nearest_level(vHSV.x, 0);
    vHSV.y = nearest_level(vHSV.y, 1);
    vHSV.z = nearest_level(vHSV.z, 2);

    output_color = vec4(HSVtoRGB(vHSV), 1);
}