//
// Created by alexandre on 24/05/19.
//

#ifndef OPENGL_GLITCH_PROGRAM_HH
#define OPENGL_GLITCH_PROGRAM_HH


#include <iostream>
#include <glad/glad.h>

class Program {
private:
    const char *load(const std::string &filename);
    void compile(GLuint shader, const char *shader_src);
    void link(GLuint vertex_shader, GLuint fragment_shader);

public:
    GLuint program_id;
    GLuint vertex_shader;
    GLuint fragment_shader;

    void build();
};


#endif //OPENGL_GLITCH_PROGRAM_HH
