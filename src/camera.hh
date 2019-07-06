//
// Created by alexandre on 28/05/19.
//

#ifndef OPENGL_GLITCH_CAMERA_HH
#define OPENGL_GLITCH_CAMERA_HH

#include <glm/glm.hpp>
#include <GLFW/glfw3.h>

enum FX_frag
{
    UNDEFINED              = 1 << 0,
    COMPUTE_LIGHT          = 1 << 1,
    TEX_BEFORE             = 1 << 2,
    TEX_MOVE               = 1 << 3,
    TEX_MOVE_GLITCH        = 1 << 4,
    COLORIZE               = 1 << 5,
    TEX_RGB_SPLIT          = 1 << 6,
    EDGE_ENHANCE           = 1 << 7,
    TOONIFY                = 1 << 8,
    HORRORIFY              = 1 << 9
};

enum FX_screen_frag
{
    SCREEN_UNDEFINED       = 1 << 0,
    SCREEN_TEX_BEFORE      = 1 << 1,
    SCREEN_TEX_RGB_SPLIT   = 1 << 2,
    SCREEN_RECTANGLES      = 1 << 3,
    SCREEN_DISTORTION      = 1 << 4,
    SCREEN_K7              = 1 << 5
};

template<typename T> inline T operator~(T a)
{
    return (T)~(int)a;
}
template<typename T> inline T operator|(T a, T b)
{
    return (T)((int)a | (int)b);
}
template<typename T> inline T& operator|=(T& a, T b)
{
    return (T&)((int&)a |= (int)b);
}
template<typename T> inline T operator&(T a, T b)
{
    return (T)((int)a & (int)b);
}

class Camera
{
public:
    glm::vec3 pos;
    glm::vec3 front;
    glm::vec3 right;
    glm::vec3 up;
    float fov;

    float speed; // motion speed (translation)
    float sensitivity; // rotation speed

    float yaw; // rotation around Y axis
    float pitch; // rotation around X axis

    float last_mouse_x;
    float last_mouse_y;
    glm::vec2 mouse_pos;

    bool first_mouse_move; // to handle the big jump on the first mouse movement

    FX_frag fx_frag_samus;
    FX_screen_frag  fx_screen_frag_samus;
    FX_frag fx_frag_background;
    FX_screen_frag  fx_screen_frag_background;

    Camera();
};


#endif //OPENGL_GLITCH_CAMERA_HH
