#version 430

in vec4 gl_FragCoord;

uniform vec4 toto;

out vec4 FragColor;

void main()
{
    FragColor = toto;//vec4(1, 0.5f, 0.2f, 1);
}
