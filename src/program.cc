//
// Created by alexandre on 24/05/19.
//

#include "program.hh"

#include <exception>
#include <fstream>


#define TEST_OPENGL_ERROR()                                                         \
  do {									                                            \
    GLenum err = glGetError();					                                    \
    if (err != GL_NO_ERROR) std::cerr << "OpenGL ERROR!" << __LINE__ << std::endl;  \
  } while(0)



const char *Program::load(const std::string &filename)
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

void Program::compile(GLuint shader, const char *shader_src)
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

void Program::link(GLuint vertex_shader, GLuint fragment_shader)
{
    glAttachShader(program_id, vertex_shader); TEST_OPENGL_ERROR();
    glAttachShader(program_id, fragment_shader); TEST_OPENGL_ERROR();
    glLinkProgram(program_id); TEST_OPENGL_ERROR();

    // check for linking errors
    int success;
    char infoLog[512];
    glGetProgramiv(program_id, GL_LINK_STATUS, &success);
    if (!success)
    {
        glGetProgramInfoLog(program_id, 512, NULL, infoLog);
        std::cerr << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
        throw std::exception();
    }
    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);
}

Program::Program(const char *vertex_path, const char *fragment_path)
{
    const char *vertex_src = load(vertex_path);
    const char *fragment_src = load(fragment_path);

    GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER); TEST_OPENGL_ERROR();
    GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER); TEST_OPENGL_ERROR();
    compile(vertex_shader, vertex_src);
    compile(fragment_shader, fragment_src);

    program_id = glCreateProgram(); TEST_OPENGL_ERROR();
    link(vertex_shader, fragment_shader);
}

void Program::set_bool(const std::string &name, bool value) const
{
    glUniform1i(glGetUniformLocation(program_id, name.c_str()), (int)value);
}

void Program::set_int(const std::string &name, int value) const
{
    glUniform1i(glGetUniformLocation(program_id, name.c_str()), value);
}

void Program::set_float(const std::string &name, float value) const
{
    glUniform1f(glGetUniformLocation(program_id, name.c_str()), value);
}

void Program::set_vec2(const std::string &name, const glm::vec2 &value) const
{
    glUniform2fv(glGetUniformLocation(program_id, name.c_str()), 1, &value[0]);
}

void Program::set_vec2(const std::string &name, float x, float y) const
{
    glUniform2f(glGetUniformLocation(program_id, name.c_str()), x, y);
}

void Program::set_vec3(const std::string &name, const glm::vec3 &value) const
{
    glUniform3fv(glGetUniformLocation(program_id, name.c_str()), 1, &value[0]);
}

void Program::set_vec3(const std::string &name, float x, float y, float z) const
{
    glUniform3f(glGetUniformLocation(program_id, name.c_str()), x, y, z);
}

void Program::set_vec4(const std::string &name, const glm::vec4 &value) const
{
    glUniform4fv(glGetUniformLocation(program_id, name.c_str()), 1, &value[0]);
}
void Program::set_vec4(const std::string &name, float x, float y, float z, float w)
{
    glUniform4f(glGetUniformLocation(program_id, name.c_str()), x, y, z, w);
}

void Program::set_mat2(const std::string &name, const glm::mat2 &mat) const
{
    glUniformMatrix2fv(glGetUniformLocation(program_id, name.c_str()), 1, GL_FALSE, &mat[0][0]);
}

void Program::set_mat3(const std::string &name, const glm::mat3 &mat) const
{
    glUniformMatrix3fv(glGetUniformLocation(program_id, name.c_str()), 1, GL_FALSE, &mat[0][0]);
}

void Program::set_mat4(const std::string &name, const glm::mat4 &mat) const
{
    glUniformMatrix4fv(glGetUniformLocation(program_id, name.c_str()), 1, GL_FALSE, &mat[0][0]);
}