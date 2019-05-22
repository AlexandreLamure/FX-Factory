//
// Created by alexandre on 22/05/19.
//

#include <glad/glad.h>
#include <iostream>
#include <exception>
#include <fstream>
#include "shader_build.hh"


#define TEST_OPENGL_ERROR()                                                         \
  do {									                                            \
    GLenum err = glGetError();					                                    \
    if (err != GL_NO_ERROR) std::cerr << "OpenGL ERROR!" << __LINE__ << std::endl;  \
  } while(0)


namespace ShaderBuild
{
    const char *load(const std::string &filename)
    {
        std::ifstream input_src_file(filename, std::ios::in);
        std::string ligne;
        std::string file_content="";
        if (input_src_file.fail()) {
            std::cerr << "FAIL\n";
            return "";
        }
        while(getline(input_src_file, ligne)) {
            file_content = file_content + ligne + "\n";
        }
        file_content += '\0';
        input_src_file.close();

        char *shader_src = (char*)std::malloc(file_content.length() * sizeof(char));
        file_content.copy(shader_src, file_content.length());
        return shader_src;
    }

    void compile(GLuint shader, const char *shader_src)
    {
        glShaderSource(shader, 1, &shader_src, nullptr); TEST_OPENGL_ERROR();
        glCompileShader(shader); TEST_OPENGL_ERROR();

        // check for shader compile errors
        int success;
        char infoLog[512];
        glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(shader, 512, nullptr, infoLog);
            std::cerr << "ERROR::SHADER::COMPILATION_FAILED\n" << infoLog << std::endl;
            throw std::exception();
        }
    }

    void link(GLuint program, GLuint vertex_shader, GLuint fragment_shader)
    {
        glAttachShader(program, vertex_shader); TEST_OPENGL_ERROR();
        glAttachShader(program, fragment_shader); TEST_OPENGL_ERROR();
        glLinkProgram(program); TEST_OPENGL_ERROR();

        // check for linking errors
        int success;
        char infoLog[512];
        glGetProgramiv(program, GL_LINK_STATUS, &success);
        if (!success)
        {
            glGetProgramInfoLog(program, 512, NULL, infoLog);
            std::cerr << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
            throw std::exception();
        }
        glDeleteShader(vertex_shader);
        glDeleteShader(fragment_shader);
    }

    GLuint build()
    {
        const char *vertex_src = load("../shaders/vertex.glsl");
        const char *fragment_src = load("../shaders/fragment.glsl");

        GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER); TEST_OPENGL_ERROR();
        GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER); TEST_OPENGL_ERROR();
        compile(vertex_shader, vertex_src);
        compile(fragment_shader, fragment_src);

        GLuint program = glCreateProgram(); TEST_OPENGL_ERROR();
        link(program, vertex_shader, fragment_shader);
        return program;
    }
}