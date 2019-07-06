#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <cmath>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <ctime>

#include "init.hh"
#include "program.hh"
#include "model.hh"
#include "camera.hh"
#include "fx-factory.hh"


Camera camera;
std::vector<FX::FX> FXs;

void mouse_callback(GLFWwindow* window, double xpos, double ypos)
{
    camera.mouse_pos.x = xpos;
    camera.mouse_pos.y = ypos;

    if (camera.first_mouse_move)
    {
        camera.last_mouse_x = xpos;
        camera.last_mouse_y = ypos;
        camera.first_mouse_move = false;
    }

    float offset_x = xpos - camera.last_mouse_x;
    float offset_y = camera.last_mouse_y - ypos;

    camera.last_mouse_x = xpos;
    camera.last_mouse_y = ypos;

    offset_x *= camera.sensitivity;
    offset_y *= camera.sensitivity;

    camera.yaw   += offset_x;
    camera.pitch += offset_y;

    if(camera.pitch > 89.0f)
        camera.pitch = 89.0f;
    if(camera.pitch < -89.0f)
        camera.pitch = -89.0f;

    camera.front.x = cos(glm::radians(camera.yaw)) * cos(glm::radians(camera.pitch));
    camera.front.y = sin(glm::radians(camera.pitch));
    camera.front.z = sin(glm::radians(camera.yaw)) * cos(glm::radians(camera.pitch));
    camera.front = glm::normalize(camera.front);
    camera.right = glm::normalize(glm::cross(camera.front, glm::vec3(0.f, 1.f, 0.f)));
    camera.up    = glm::normalize(glm::cross(camera.right, camera.front));
}

void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    camera.fov -= yoffset;

    if(camera.fov <= 1.0f)
        camera.fov = 1.0f;
    if(camera.fov >= 45.0f)
        camera.fov = 45.0f;
}

template<typename T>
void toggle(T& a, T b)
{
    a = a & b ? a & ~b : a | b;
}

void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
    if (key == GLFW_KEY_E && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::UNDEFINED);
    if (key == GLFW_KEY_R && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::COMPUTE_LIGHT);
    if (key == GLFW_KEY_T && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::TEX_BEFORE);
    if (key == GLFW_KEY_Y && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::TEX_MOVE);
    if (key == GLFW_KEY_U && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::TEX_MOVE_GLITCH);
    if (key == GLFW_KEY_I && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::COLORIZE);
    if (key == GLFW_KEY_O && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::TEX_RGB_SPLIT);
    if (key == GLFW_KEY_P && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::EDGE_ENHANCE);
    if (key == GLFW_KEY_G && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::TOONIFY);
    if (key == GLFW_KEY_H && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::HORRORIFY);

    if (key == GLFW_KEY_Z && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx, FX_frag::HORRORIFY);
    if (key == GLFW_KEY_X && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::HORRORIFY);
    if (key == GLFW_KEY_C && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::HORRORIFY);
    if (key == GLFW_KEY_V && action == GLFW_PRESS)
        toggle<FX_frag>(camera.fx_frag_samus, FX_frag::HORRORIFY);
}

void process_input(GLFWwindow *window, float delta_time)
{
    float delta_speed = camera.speed * delta_time;

    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.pos += delta_speed * camera.front;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.pos -= delta_speed * camera.front;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.pos += delta_speed * camera.right;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.pos -= delta_speed * camera.right;
    if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        camera.pos += delta_speed * camera.up;
    if (glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS)
        camera.pos -= delta_speed * camera.up;
}


void set_uniforms(Program& program, int window_w, int window_h, float total_time, float delta_time)
{
    glUseProgram(program.program_id);

    // set uniforms
    program.set_float("total_time", total_time);
    program.set_float("delta_time", delta_time);
    program.set_vec2("resolution", window_w, window_h);
    // set random
    program.set_int("rand", std::rand() % 100);
    // set lights
    program.set_vec3("ambient_light_color", 0.5f, 0.5f, 0.5f);
    program.set_vec3("light1_color", 1.0f, 1.0f, 1.0f);
    program.set_vec3("light1_position", -5.0f, 15.0f, 10.0f);
    program.set_vec3("light2_color", 0.8f, 0.0f + (cos(total_time)), 0.3f);
    program.set_vec3("light2_position", 5.0f, 0.0f, 2.0f);
    program.set_vec3("camera_pos", camera.pos);
    program.set_vec2("mouse_pos", camera.mouse_pos);

    glm::mat4 view = glm::lookAt(camera.pos, camera.pos + camera.front, camera.up);
    program.set_mat4("view", view);

    glm::mat4 projection = glm::perspective(glm::radians(camera.fov), (float)window_w/(float)window_h, 0.1f, 1000.0f);
    program.set_mat4("projection", projection);
}

int main()
{
    // window variables
    int window_w = 800;
    int window_h = 600;

    // time variables
    float total_time = 0.f;
    float delta_time = 0.f;
    float last_time = 0.f;

    // random
    std::srand(std::time(nullptr));

    GLFWwindow *window = Init::init_all(window_w, window_h);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    glfwSetKeyCallback(window, key_callback);

    auto vertex_paths = std::vector<const char*>{"../shaders/vertex/basic.glsl"};
    auto fragment_paths = std::vector<const char*>{"../shaders/random.glsl",
                                                   "../shaders/fragment/compute-lights.glsl",
                                                   "../shaders/fragment/tex-move.glsl",
                                                   "../shaders/fragment/colorize.glsl",
                                                   "../shaders/fragment/tex-rgb-split.glsl",
                                                   "../shaders/fragment/edge.glsl",
                                                   "../shaders/fragment/hsv.glsl",
                                                   "../shaders/fragment/horror.glsl",
                                                   "../shaders/fragment/all.glsl"};
    Program program_classic(vertex_paths, fragment_paths);

    // Copy of classic program, with undefined behaviour
    auto fragment_paths_u = std::vector<const char*>{"../shaders/random.glsl",
                                                   "../shaders/fragment/compute-lights.glsl",
                                                   "../shaders/fragment/tex-move.glsl",
                                                   "../shaders/fragment/colorize.glsl",
                                                   "../shaders/fragment/tex-rgb-split.glsl",
                                                   "../shaders/fragment/edge.glsl",
                                                   "../shaders/fragment/hsv.glsl",
                                                   "../shaders/fragment/horror.glsl",
                                                   "../shaders/fragment/all-undefined.glsl"};
    Program program_undefined(vertex_paths, fragment_paths_u);


    auto screen_vertex_paths = std::vector<const char*>{"../shaders/vertex/screen/basic.glsl"};
    auto screen_fragment_paths = std::vector<const char*>{"../shaders/random.glsl",
                                                          "../shaders/fragment/screen/tex-rgb-split.glsl",
                                                          "../shaders/fragment/screen/distortion.glsl",
                                                          "../shaders/fragment/screen/rectangles.glsl",
                                                          "../shaders/fragment/screen/k7.glsl",
                                                          "../shaders/fragment/screen/all.glsl"};
    Program program_screen(screen_vertex_paths, screen_fragment_paths);

    // Copy of classic screen program, with undefined behaviour
    /*auto screen_fragment_paths_undefined = std::vector<const char*>{"../shaders/random.glsl",
                                                          "../shaders/fragment/screen/tex-rgb-split.glsl",
                                                          "../shaders/fragment/screen/distortion.glsl",
                                                          "../shaders/fragment/screen/rectangles.glsl",
                                                          "../shaders/fragment/screen/k7.glsl",
                                                          "../shaders/fragment/screen/all-undefined.glsl"};
    Program program_screen_undefined(screen_vertex_paths, screen_fragment_paths_undefined);*/


    Model samus("../resources/varia-suit/DolBarriersuit.obj");
    Model background("../resources/varia-suit/background.obj");

    //Model spitfire("../resources/spitfire/SpitFire.obj");
    //Model classroom("../resources/animeclassroom/anime school.obj");


    FXs = std::vector<FX::FX>(2);


    // screen quad
    float quad_vertices[] = {
            // positions
            -1.0f,  1.0f,  0.0f, 1.0f,
            -1.0f, -1.0f,  0.0f, 0.0f,
            1.0f, -1.0f,  1.0f, 0.0f,
            /* texCoords */
            -1.0f,  1.0f,  0.0f, 1.0f,
            1.0f, -1.0f,  1.0f, 0.0f,
            1.0f,  1.0f,  1.0f, 1.0f
    };
    // screen quad VAO
    unsigned int quadVAO;
    unsigned int quadVBO;
    glGenVertexArrays(1, &quadVAO);
    glGenBuffers(1, &quadVBO);
    glBindVertexArray(quadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quad_vertices), &quad_vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(2 * sizeof(float)));

    // framebuffer configuration
    // -------------------------
    unsigned int frame_buffer;
    glGenFramebuffers(1, &frame_buffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer);
    // create a color attachment texture
    unsigned int texture_color_buffer;
    glGenTextures(1, &texture_color_buffer);
    glBindTexture(GL_TEXTURE_2D, texture_color_buffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, window_w, window_h, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_color_buffer, 0);
    // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
    unsigned int rbo;
    glGenRenderbuffers(1, &rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, window_w, window_h); // use a single renderbuffer object for both a depth AND stencil buffer.
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo); // now actually attach it
    // now that we actually created the framebuffer and added all attachments we want to check if it is actually complete now
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        std::cerr << "ERROR::FRAMEBUFFER:: Framebuffer is not complete!" << std::endl;
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // main loop
    while(!glfwWindowShouldClose(window))
    {
        // update delta_time
        total_time = glfwGetTime();
        delta_time = total_time - last_time;
        last_time = total_time;

        // input
        process_input(window, delta_time);

        // render
        glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer); // draw scene to color texture
        glEnable(GL_DEPTH_TEST);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);



        // SAMUS -------------------------------------------------------------------------------------------------------
        Program program_samus;
        // Choose undefined of classic program
        if (FXs[0].frag_render & FX::FragRender::UNDEFINED)
            program_samus.program_id = program_undefined.program_id;
        else
            program_samus.program_id = program_classic.program_id;
        // Set classic uniforms
        set_uniforms(program_samus, window_w, window_h, total_time, delta_time);
        // set FX
        program_samus.set_int("FX", FXs[0].frag_render);
        // set Model matrix
        glm::mat4 model_mat = glm::mat4(1.f);
        model_mat = glm::translate(model_mat, glm::vec3(-0.3, -10.f, -3.f));
        model_mat = glm::rotate(model_mat, total_time * glm::radians(20.f), glm::vec3(0.f, 1.f, 0.f));
        program_samus.set_mat4("model", model_mat);
        // Draw
        samus.draw(program_samus);
        // -------------------------------------------------------------------------------------------------------------



        // BACKGROUND --------------------------------------------------------------------------------------------------
        Program program_background;
        // Choose undefined of classic program
        if (FXs[1].frag_render & FX::FragRender::UNDEFINED)
            program_background.program_id = program_undefined.program_id;
        else
            program_background.program_id = program_classic.program_id;
        // Set classic uniforms
        set_uniforms(program_background, window_w, window_h, total_time, delta_time);
        // set FX
        program_samus.set_int("FX", FXs[1].frag_render);
        // set Model matrix
        model_mat = glm::mat4(1.f);
        model_mat = glm::translate(model_mat, glm::vec3(-0.3, -10.f, -3.f));
        program_background.set_mat4("model", model_mat);
        // Draw
        background.draw(program_background);
        // -------------------------------------------------------------------------------------------------------------



/*
        // spitfire
        glm::mat4 model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(0., -10.f, -20.f));
        tmp.set_mat4("model", model);
        spitfire.draw(tmp);
*/

        // classroom
        /*glm::mat4 model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-5.f, -3.f, 18.f));
        model = glm::rotate(model, glm::radians(180.f), glm::vec3(0.f, 1.f, 0.f));
        program.set_mat4("model", model);
        classroom.draw(program);*/



        // draw a quad with the framebuffer color texture
        glBindFramebuffer(GL_FRAMEBUFFER, 0); // bind back to default framebuffer
        glDisable(GL_DEPTH_TEST);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(program_screen.program_id);

        program_screen.set_int("screen_texture", 0);
        program_screen.set_float("total_time", total_time);
        program_screen.set_float("delta_time", delta_time);
        program_screen.set_vec2("resolution", window_w, window_h);
        program_screen.set_int("rand", std::rand() % 100);


        // SCREEN ------------------------------------------------------------------------------------------------------
        // Set classic uniforms
        set_uniforms(program_screen, window_w, window_h, total_time, delta_time);
        // set FX
        //program_background.set_int("FX", camera.fx_screen);
        // Draw
        glBindVertexArray(quadVAO);
        glBindTexture(GL_TEXTURE_2D, texture_color_buffer);	// use the color attachment texture as the texture of the quad plane
        glDrawArrays(GL_TRIANGLES, 0, 6);
        // -------------------------------------------------------------------------------------------------------------




        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }


    // glfw: terminate, clearing all previously allocated GLFW resources.
    // ------------------------------------------------------------------
    glDeleteVertexArrays(1, &quadVAO);
    glDeleteBuffers(1, &quadVBO);
    glfwTerminate();

    return 0;
}