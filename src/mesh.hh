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
    glm::vec3 Position;
    glm::vec3 Normal;
    glm::vec2 TexCoords;
};

struct Texture {
    unsigned int id;
    std::string type;
};

class Mesh {
public:
    std::vector<Vertex> vertices;
    std::vector<unsigned int> indices;
    std::vector<Texture> textures;

    Mesh(std::vector<Vertex> vertices, std::vector<unsigned int> indices, std::vector<Texture> textures);
    void Draw(Program program);

private:
    unsigned int VAO, VBO, EBO;

    void setupMesh();
};


#endif //OPENGL_GLITCH_MESH_HH
