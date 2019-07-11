//
// Created by alex-thinkpad on 11/07/19.
//

#ifndef OPENGL_GLITCH_SCREEN_H
#define OPENGL_GLITCH_SCREEN_H


class Screen
{
public:
    GLuint quadVAO;
    GLuint texture_color_buffer;

    Screen();
    GLuint gen_fbo(int window_w, int window_h);
    void draw();
};


#endif //OPENGL_GLITCH_SCREEN_H
