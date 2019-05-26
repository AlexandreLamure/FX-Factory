//
// Created by alexandre on 24/05/19.
//

#ifndef OPENGL_GLITCH_MODEL_HH
#define OPENGL_GLITCH_MODEL_HH

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include "mesh.hh"

class Model {
private:
    std::vector<Mesh> meshes;
    std::string directory;
    std::vector<Texture> textures_loaded;

    void process_node(aiNode *node, const aiScene *scene);
    Mesh process_mesh(aiMesh *mesh, const aiScene *scene);
    std::vector<Texture> load_material_textures(aiMaterial *mat, aiTextureType type, std::string type_name);
    unsigned int texture_from_file(const char *path, const std::string &directory);


public:
    Model(std::string path);

    void draw(Program shader);
};


#endif //OPENGL_GLITCH_MODEL_HH
