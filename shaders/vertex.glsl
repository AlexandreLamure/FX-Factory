#version 430

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 tex_coords;

out vec4 interpolated_pos;
out vec3 interpolated_normal;
out vec4 interpolated_color;
out vec2 interpolated_tex_coords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform int mesh_id;
uniform float total_time;
uniform int rand;



void main()
{
    vec3 position_glitch = position;
    float glitch_intensity = 0.007;
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
    interpolated_pos = model * vec4(position_glitch, 1);
    interpolated_normal = mat3(transpose(inverse(model))) * normal; // we only keep the scale and rotations from model matrix


    gl_Position = projection * view * interpolated_pos;

    interpolated_tex_coords = tex_coords;
}
