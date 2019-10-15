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

void Program::compile(GLuint shader, const char *shader_src, const char* shader_path)
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
        std::cerr << "ERROR::SHADER::COMPILATION_FAILED: " << shader_path << std::endl << infoLog << std::endl;
        throw std::exception();
    }
}

void Program::link(const std::vector<GLuint>& vertex_shaders, const std::vector<GLuint>& fragment_shaders)
{
    for (auto vertex_shader : vertex_shaders)
    {
        glAttachShader(program_id, vertex_shader);
        TEST_OPENGL_ERROR();

    }
    for (auto fragment_shader : fragment_shaders)
    {
        glAttachShader(program_id, fragment_shader);
        TEST_OPENGL_ERROR();
    }
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
    for (auto vertex_shader : vertex_shaders)
    {
        glDetachShader(program_id, vertex_shader);
        glDeleteShader(vertex_shader);
    }
    for (auto fragment_shader : fragment_shaders)
    {
        glDetachShader(program_id, fragment_shader);
        glDeleteShader(fragment_shader);
    }
}

Program::Program(const std::vector<const char*>& vertex_paths, const std::vector<const char*>& fragment_paths)
{
    std::vector<const char*> vertex_srcs(vertex_paths.size());
    std::vector<const char*> fragment_srcs(fragment_paths.size());

    for (int i = 0; i < vertex_paths.size(); ++i)
        vertex_srcs[i] = load(vertex_paths[i]);
    for (int i = 0; i < fragment_paths.size(); ++i)
        fragment_srcs[i] = load(fragment_paths[i]);

    std::vector<GLuint> vertex_shaders(vertex_srcs.size());
    std::vector<GLuint> fragment_shaders(fragment_srcs.size());

    for (int i = 0; i < vertex_srcs.size(); ++i)
    {
        vertex_shaders[i] = glCreateShader(GL_VERTEX_SHADER);
        TEST_OPENGL_ERROR();
    }
    for (int i = 0; i < fragment_srcs.size(); ++i)
    {
        fragment_shaders[i] = glCreateShader(GL_FRAGMENT_SHADER);
        TEST_OPENGL_ERROR();
    }
    for (int i = 0; i < vertex_shaders.size(); ++i)
        compile(vertex_shaders[i], vertex_srcs[i], vertex_paths[i]);
    for (int i = 0; i < fragment_shaders.size(); ++i)
        compile(fragment_shaders[i], fragment_srcs[i], fragment_paths[i]);
    program_id = glCreateProgram(); TEST_OPENGL_ERROR();

    link(vertex_shaders, fragment_shaders);
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