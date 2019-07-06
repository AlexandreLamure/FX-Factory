//
// Created by alex-thinkpad on 06/07/19.
//

#ifndef OPENGL_GLITCH_FX_FACTORY_HH
#define OPENGL_GLITCH_FX_FACTORY_HH

#include <vector>

namespace FX {
    enum FragRender {
        UNDEFINED = 1 << 0,
        COMPUTE_LIGHT = 1 << 1,
        TEX_BEFORE = 1 << 2,
        TEX_MOVE = 1 << 3,
        TEX_MOVE_GLITCH = 1 << 4,
        COLORIZE = 1 << 5,
        TEX_RGB_SPLIT = 1 << 6,
        EDGE_ENHANCE = 1 << 7,
        TOONIFY = 1 << 8,
        HORRORIFY = 1 << 9
    };

    enum FragScreen {
        SCREEN_UNDEFINED = 1 << 0,
        SCREEN_TEX_BEFORE = 1 << 1,
        SCREEN_TEX_RGB_SPLIT = 1 << 2,
        SCREEN_RECTANGLES = 1 << 3,
        SCREEN_DISTORTION = 1 << 4,
        SCREEN_K7 = 1 << 5
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
        //std::vector<VertexRender> vertex_renders;
        std::vector<FragRender> frag_renders;
        FragScreen frag_screen;
        int current_model;

        FXFactory()
        {};
        FXFactory(int nb_models);
    };

};
#endif //OPENGL_GLITCH_FX_FACTORY_HH