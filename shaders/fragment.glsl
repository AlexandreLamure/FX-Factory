#version 430

in vec4 gl_FragCoord;

uniform float time;

out vec4 FragColor;

void main()
{
    FragColor = vec4(cos(2*time) / 2., sin(time) / 2., 0.2f, 1);
}
