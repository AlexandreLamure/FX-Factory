//
// Created by alex-thinkpad on 06/07/19.
//

#ifndef OPENGL_GLITCH_FX_FACTORY_HH
#define OPENGL_GLITCH_FX_FACTORY_HH

#include <vector>

namespace FX
{
    enum VertexRender
    {
        TEX_TRANSPOSE           = 1 << 0,
        WATER                   = 1 << 1
    };

    enum FragRender
    {
        UNDEFINED               = 1 << 0,
        COMPUTE_LIGHT           = 1 << 1,
        TEX_MOVE                = 1 << 2,
        TEX_MOVE_GLITCH         = 1 << 3,
        COLORIZE                = 1 << 4,
        TEX_RGB_SPLIT           = 1 << 5,
        EDGE_ENHANCE            = 1 << 6,
        TOONIFY                 = 1 << 7,
        HORRORIFY               = 1 << 8,
        PIXELIZE                = 1 << 9
    };

    enum FragScreen
    {
        SCREEN_UNDEFINED        = 1 << 0,
        SCREEN_TEX_BEFORE       = 1 << 1,
        SCREEN_TEX_RGB_SPLIT    = 1 << 2,
        SCREEN_RECTANGLES       = 1 << 3,
        SCREEN_DISTORTION       = 1 << 4,
        SCREEN_K7               = 1 << 5,
        SCREEN_PIXELIZE         = 1 << 6,
        SCREEN_RAIN             = 1 << 7
    };

    template<typename T>
    inline T operator~(T a) {
        return (T) ~(int) a;
    }

    template<typename T>
    inline T operator|(T a, T b) {
        return (T) ((int) a | (int) b);
    }

    template<typename T>
    inline T &operator|=(T &a, T b) {
        return (T &) ((int &) a |= (int) b);
    }

    template<typename T>
    inline T operator&(T a, T b) {
        return (T) ((int) a & (int) b);
    }

    class FXFactory
    {
    public:
        std::vector<VertexRender> vertex_renders;
        std::vector<FragRender> frag_renders;
        FragScreen frag_screen;
        int factory_level_render;
        int factory_level_screen;
        int current_model;
        int tex_id_glitch;

        FXFactory()
        {};
        FXFactory(int nb_models);
    };

};
#endif //OPENGL_GLITCH_FX_FACTORY_HH