#version 430

vec4 colorize(vec4 interpolated_pos, vec3 interpolated_normal,
              float total_time,
              int mesh_id, int rand,
              vec4 color_org, int level)
{

    if (level > 0)
    {
        vec4 glitch_color = vec4(0);
        if (rand % 11 == rand % 13 && // rate
            int((mesh_id + 10) * fract(total_time)) == int((mesh_id + 10) * sin(total_time)))
        {
            glitch_color = 1.0 * interpolated_pos * cos(total_time);
            glitch_color.g += cos(rand);
            glitch_color.b *= rand;
        }
        color_org += glitch_color;
    }
    if (level > 1)
    {
        vec4 glitch_color2 = vec4(0);
        if (mesh_id % 10 == int(total_time) % 7 &&
            (int(6*cos(interpolated_normal.y + cos(0.1*total_time))) == int((6.1 + 0.05 * cos(total_time))*sin(interpolated_normal.z))))
        {
            glitch_color2 = 1.0 * interpolated_pos * sin(total_time);
            glitch_color2.r *= cos(total_time);
            glitch_color2.b *= fract(total_time);
        }
        color_org -= glitch_color2;
    }
    if (level > 2)
    {
        vec4 glitch_color3 = vec4(0);
        if (rand % 20 == rand % 18 &&// rate
            mesh_id % 15 == rand % 15 &&// target mesh
            ((rand % 3 == 0 && int(fract(interpolated_pos.x*rand)) % 8 == int(total_time) % 2) ||
            (rand % 3 == 1 && int(fract(interpolated_pos.y*rand)) % 8 == int(total_time) % 2) ||
            (rand % 3 == 2 && int(fract(interpolated_pos.z*rand)) % 8 == int(total_time) % 2))
        )
        {
            glitch_color3 = 1.0 * interpolated_pos * cos(total_time);
            glitch_color3.r += 1;
            glitch_color3.b *= fract(total_time);
        }
        color_org -= glitch_color3;
    }

    return color_org;
}