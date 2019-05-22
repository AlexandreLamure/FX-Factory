//
// Created by alexandre on 22/05/19.
//

#ifndef OPENGL_GLITCH_INIT_HH
#define OPENGL_GLITCH_INIT_HH

namespace Init
{
    void framebuffer_size_callback(GLFWwindow* window, int width, int height);
    void init_glfw();
    GLFWwindow *init_window(int width, int height);
    void init_glad();

    GLFWwindow *init_all(int width, int height);
}


#endif //OPENGL_GLITCH_INIT_HH