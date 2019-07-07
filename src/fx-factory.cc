//
// Created by alex-thinkpad on 06/07/19.
//

#include <iostream>
#include "fx-factory.hh"

namespace FX
{
    FXFactory::FXFactory(int nb_models)
    {
        vertex_renders = std::vector<VertexRender>(nb_models);
        frag_renders = std::vector<FragRender>(nb_models);

        for (int i = 0; i < nb_models; ++i)
            frag_renders[i] = FragRender::COMPUTE_LIGHT | FragRender::TEX_BEFORE;

        frag_screen = FragScreen::SCREEN_TEX_BEFORE;
        current_model = 0;
        tex_id_glitch = 0;
    }
}