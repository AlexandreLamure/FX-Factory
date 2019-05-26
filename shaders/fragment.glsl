#version 430

in vec4 gl_FragCoord;

uniform float total_time;

out vec4 FragColor;

void main()
{
    FragColor = vec4(cos(2*total_time) / 2., sin(total_time) / 2., 0.2f, 1);
}
