#version 430

vec3 tex_transpose(vec3 position, float total_time, int mesh_id, int rand, float glitch_intensity)
{
    vec3 position_glitch = position;

    if (rand % 50 == int(total_time) % 50)
    {
        if (int(10*position.y) % 3 == 0)
        {
            position_glitch.x += glitch_intensity * rand;
            position_glitch.y -= glitch_intensity * rand;
        }
        else if (int(10*position.y) % 3 == 1)
            position_glitch.x -= glitch_intensity * rand;
    }
    if (abs(cos(total_time)) < 0.13
        && mesh_id % 100 == rand)
    {
        position_glitch *= 1.08;
    }

    return position_glitch;
}
