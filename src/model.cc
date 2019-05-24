//
// Created by alexandre on 24/05/19.
//

#include "model.hh"

Model::Model(char *path)
{
    load_model(path);
}

void Model::draw(Program shader)
{
    for(unsigned int i = 0; i < meshes.size(); i++)
        meshes[i].draw(shader);
}

void Model::load_model(std::string path)
{
    Assimp::Importer import;
    const aiScene *scene = import.ReadFile(path, aiProcess_Triangulate | aiProcess_FlipUVs);

    if(!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode)
    {
        std::cout << "ERROR::ASSIMP::" << import.GetErrorString() << std::endl;
        return;
    }
    directory = path.substr(0, path.find_last_of('/'));

    process_node(scene->mRootNode, scene);
}

void Model::process_node(aiNode *node, const aiScene *scene)
{

}
