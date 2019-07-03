//
// Created by alexandre on 22/05/19.
//

#ifndef OPENGL_GLITCH_MESH_HH
#define OPENGL_GLITCH_MESH_HH

#include <iostream>
#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <vector>
#include "program.hh"


struct Vertex {
    glm::vec3 position;
    glm::vec3 normal;
    glm::vec2 tex_coords;
};

struct Texture {
    unsigned int id;
    std::string type;
    std::string path;
};

class Mesh {
public:
    std::vector<Vertex> vertices;
    std::vector<unsigned int> indices;
    std::vector<Texture> textures;

    Mesh(std::vector<Vertex> vertices, std::vector<unsigned int> indices, std::vector<Texture> textures);
    void draw(Program program, int tex_id_glitch = 0);

private:
    unsigned int VAO, VBO, EBO;

    void setupMesh();
};


#endif //OPENGL_GLITCH_MESH_HH
