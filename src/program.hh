//
// Created by alexandre on 24/05/19.
//

#ifndef OPENGL_GLITCH_PROGRAM_HH
#define OPENGL_GLITCH_PROGRAM_HH


#include <iostream>
#include <glad/glad.h>
#include <glm/vec2.hpp>
#include <glm/vec3.hpp>
#include <glm/vec4.hpp>
#include <glm/mat2x2.hpp>

class Program {
private:
    const char *load(const std::string &filename);
    void compile(GLuint shader, const char *shader_src);
    void link(GLuint vertex_shader, GLuint fragment_shader);

public:
    GLuint program_id;

    void build(const char *vertex_path, const char *fragment_path);

    void set_bool(const std::string &name, bool value) const;
    void set_int(const std::string &name, int value) const;
    void set_float(const std::string &name, float value) const;
    void set_vec2(const std::string &name, const glm::vec2 &value) const;
    void set_vec2(const std::string &name, float x, float y) const;
    void set_vec3(const std::string &name, const glm::vec3 &value) const;
    void set_vec3(const std::string &name, float x, float y, float z) const;
    void set_vec4(const std::string &name, const glm::vec4 &value) const;
    void set_vec4(const std::string &name, float x, float y, float z, float w);
    void set_mat2(const std::string &name, const glm::mat2 &mat) const;
    void set_mat3(const std::string &name, const glm::mat3 &mat) const;
    void set_mat4(const std::string &name, const glm::mat4 &mat) const;
};


#endif //OPENGL_GLITCH_PROGRAM_HH
