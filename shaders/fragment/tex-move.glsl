#version 430

vec4 tex_move_glitch(vec2 uv,
                     sampler2D texture_diffuse1,
                     float total_time,
                     int mesh_id, int rand,
                     int rate)
{
    vec2 uv_glitch = vec2(uv.x + 0.1 * total_time,
                                               uv.y + 0.1 * total_time);

    vec4 texel1 = texture(texture_diffuse1, uv);
    vec4 texel2 = texture(texture_diffuse1, uv_glitch);

    bool activate = rand % 10 >= rate || (rand * mesh_id % 100 == rand % 5);
    vec4 texel = mix(texel1, texel2, cos(total_time) * int(activate));

    return texel;
}
