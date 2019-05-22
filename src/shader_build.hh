//
// Created by alexandre on 22/05/19.
//

#ifndef OPENGL_GLITCH_LINK_HH
#define OPENGL_GLITCH_LINK_HH

namespace ShaderBuild
{
    void compile(GLuint shader, const char *shader_src);
    void link(GLuint program, GLuint vertex_shader, GLuint fragment_shader);

    GLuint build();
}

#endif //OPENGL_GLITCH_LINK_HH
