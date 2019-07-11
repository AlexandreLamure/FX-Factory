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
#include "screen.h"


Camera camera;
FX::FXFactory fx_factory;

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
    // reset FX
    if (key == GLFW_KEY_BACKSPACE && action == GLFW_PRESS)
    {
        fx_factory.tex_id_glitch = 0;
        fx_factory.factory_level_render = 0;
        fx_factory.vertex_renders[fx_factory.current_model] = (FX::VertexRender)0;
        fx_factory.frag_renders[fx_factory.current_model] = FX::FragRender::COMPUTE_LIGHT | FX::FragRender::TEX_BEFORE;
        fx_factory.frag_screen = FX::FragScreen::SCREEN_TEX_BEFORE;
    }

    // Change texture id loading
    if (key == GLFW_KEY_RIGHT && action == GLFW_PRESS)
        fx_factory.tex_id_glitch++;
    if (key == GLFW_KEY_LEFT && action == GLFW_PRESS)
        fx_factory.tex_id_glitch--;

    // Change selected model
    if (key == GLFW_KEY_1 && action == GLFW_PRESS)
        fx_factory.current_model = 0;
    if (key == GLFW_KEY_2 && action == GLFW_PRESS)
        fx_factory.current_model = 1;

    // Set Factory level
    if (key == GLFW_KEY_UP && action == GLFW_PRESS)
        fx_factory.factory_level_render += 1;
    if (key == GLFW_KEY_DOWN && action == GLFW_PRESS)
        fx_factory.factory_level_render -= 1;
    if (key == GLFW_KEY_PAGE_UP && action == GLFW_PRESS)
        fx_factory.factory_level_screen += 1;
    if (key == GLFW_KEY_PAGE_DOWN && action == GLFW_PRESS)
        fx_factory.factory_level_screen -= 1;

    // Vertex render
    if (key == GLFW_KEY_0 && action == GLFW_PRESS)
        toggle(fx_factory.vertex_renders[fx_factory.current_model], FX::VertexRender::TEX_TRANSPOSE);
    if (key == GLFW_KEY_9 && action == GLFW_PRESS)
        toggle(fx_factory.vertex_renders[fx_factory.current_model], FX::VertexRender::WATER);

    // Fragment render
    if (key == GLFW_KEY_E && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::UNDEFINED);
    if (key == GLFW_KEY_R && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::COMPUTE_LIGHT);
    if (key == GLFW_KEY_T && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::TEX_BEFORE);
    if (key == GLFW_KEY_Y && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::TEX_MOVE);
    if (key == GLFW_KEY_U && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::TEX_MOVE_GLITCH);
    if (key == GLFW_KEY_I && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::COLORIZE);
    if (key == GLFW_KEY_O && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::TEX_RGB_SPLIT);
    if (key == GLFW_KEY_P && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::EDGE_ENHANCE);
    if (key == GLFW_KEY_G && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::TOONIFY);
    if (key == GLFW_KEY_H && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::HORRORIFY);
    if (key == GLFW_KEY_J && action == GLFW_PRESS)
        toggle(fx_factory.frag_renders[fx_factory.current_model], FX::FragRender::PIXELIZE);

    // Fragment screen
    if (key == GLFW_KEY_Z && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_UNDEFINED);
    if (key == GLFW_KEY_X && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_TEX_BEFORE);
    if (key == GLFW_KEY_C && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_TEX_RGB_SPLIT);
    if (key == GLFW_KEY_V && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_RECTANGLES);
    if (key == GLFW_KEY_B && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_DISTORTION);
    if (key == GLFW_KEY_N && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_K7);
    if (key == GLFW_KEY_M && action == GLFW_PRESS)
        toggle(fx_factory.frag_screen, FX::FragScreen::SCREEN_PIXELIZE);

    std::cout << "current model = " << fx_factory.current_model << std::endl
              << "frag_render = " << fx_factory.frag_renders[fx_factory.current_model] << std::endl
              << "frag_screen = " << fx_factory.frag_screen << std::endl;

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
    int window_w = 1200;
    int window_h = 1000;

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

    auto vertex_paths = std::vector<const char*>{"../shaders/tools.glsl",
                                                 "../shaders/simplex.glsl",
                                                 "../shaders/vertex/water.glsl",
                                                 "../shaders/vertex/tex-transpose.glsl",
                                                 "../shaders/vertex/all.glsl"};
    auto fragment_paths = std::vector<const char*>{"../shaders/tools.glsl",
                                                   "../shaders/simplex.glsl",
                                                   "../shaders/fragment/compute-lights.glsl",
                                                   "../shaders/fragment/tex-move.glsl",
                                                   "../shaders/fragment/colorize.glsl",
                                                   "../shaders/fragment/tex-rgb-split.glsl",
                                                   "../shaders/fragment/edge.glsl",
                                                   "../shaders/fragment/hsv.glsl",
                                                   "../shaders/fragment/horror.glsl",
                                                   "../shaders/fragment/pixelize.glsl",
                                                   "../shaders/fragment/all.glsl"};
    Program program_classic(vertex_paths, fragment_paths);

    // Copy of classic program, with undefined behaviour
    auto fragment_paths_u = std::vector<const char*>{"../shaders/tools.glsl",
                                                     "../shaders/simplex.glsl",
                                                     "../shaders/fragment/compute-lights.glsl",
                                                     "../shaders/fragment/tex-move.glsl",
                                                     "../shaders/fragment/colorize.glsl",
                                                     "../shaders/fragment/tex-rgb-split.glsl",
                                                     "../shaders/fragment/edge.glsl",
                                                     "../shaders/fragment/hsv.glsl",
                                                     "../shaders/fragment/horror.glsl",
                                                     "../shaders/fragment/pixelize.glsl",
                                                     "../shaders/fragment/all-undefined.glsl"};
    Program program_undefined(vertex_paths, fragment_paths_u);


    auto screen_vertex_paths = std::vector<const char*>{"../shaders/vertex/screen/basic.glsl"};
    auto screen_fragment_paths = std::vector<const char*>{"../shaders/tools.glsl",
                                                          "../shaders/simplex.glsl",
                                                          "../shaders/fragment/screen/tex-rgb-split.glsl",
                                                          "../shaders/fragment/screen/distortion.glsl",
                                                          "../shaders/fragment/screen/rectangles.glsl",
                                                          "../shaders/fragment/screen/k7.glsl",
                                                          "../shaders/fragment/screen/pixelize.glsl",
                                                          "../shaders/fragment/screen/all.glsl"};
    Program program_screen_classic(screen_vertex_paths, screen_fragment_paths);

    // Copy of classic screen program, with undefined behaviour
    auto screen_fragment_paths_undefined = std::vector<const char*>{"../shaders/tools.glsl",
                                                                    "../shaders/simplex.glsl",
                                                                    "../shaders/fragment/screen/tex-rgb-split.glsl",
                                                                    "../shaders/fragment/screen/distortion.glsl",
                                                                    "../shaders/fragment/screen/rectangles.glsl",
                                                                    "../shaders/fragment/screen/k7.glsl",
                                                                    "../shaders/fragment/screen/pixelize.glsl",
                                                                    "../shaders/fragment/screen/all-undefined.glsl"};
    Program program_screen_undefined(screen_vertex_paths, screen_fragment_paths_undefined);


    Model samus("../resources/varia-suit/DolBarriersuit.obj");
    Model background("../resources/varia-suit/background.obj");
    //Model test("../resources/drogon-gate/Landmark.obj");

    Screen screen = Screen();
    GLuint frame_buffer = screen.gen_fbo(window_w, window_h);


    fx_factory = FX::FXFactory(2);


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
        if (fx_factory.frag_renders[0] & FX::FragRender::UNDEFINED)
            program_samus.program_id = program_undefined.program_id;
        else
            program_samus.program_id = program_classic.program_id;
        glUseProgram(program_samus.program_id);
        // Set classic uniforms
        set_uniforms(program_samus, window_w, window_h, total_time, delta_time);
        // set FX
        program_samus.set_int("FXVertex", fx_factory.vertex_renders[0]);
        program_samus.set_int("FXFrag", fx_factory.frag_renders[0]);
        program_samus.set_int("factory_level_render", fx_factory.factory_level_render);
        // set Model matrix
        glm::mat4 model_mat = glm::mat4(1.f);
        model_mat = glm::translate(model_mat, glm::vec3(-0.3, -10.f, -3.f));
        model_mat = glm::rotate(model_mat, total_time * glm::radians(20.f), glm::vec3(0.f, 1.f, 0.f));
        program_samus.set_mat4("model", model_mat);
        // Draw
        samus.draw(program_samus, fx_factory.tex_id_glitch);
        // -------------------------------------------------------------------------------------------------------------



        // BACKGROUND --------------------------------------------------------------------------------------------------
        Program program_background;
        // Choose undefined of classic program
        if (fx_factory.frag_renders[1] & FX::FragRender::UNDEFINED)
            program_background.program_id = program_undefined.program_id;
        else
            program_background.program_id = program_classic.program_id;
        glUseProgram(program_background.program_id);
        // Set classic uniforms
        set_uniforms(program_background, window_w, window_h, total_time, delta_time);
        // set FX
        program_background.set_int("FXVertex", fx_factory.vertex_renders[1]);
        program_background.set_int("FXFrag", fx_factory.frag_renders[1]);
        program_background.set_int("factory_level_render", fx_factory.factory_level_render);
        // set Model matrix
        model_mat = glm::mat4(1.f);
        model_mat = glm::translate(model_mat, glm::vec3(-0.3, -10.f, -3.f));
        program_background.set_mat4("model", model_mat);
        // Draw
        background.draw(program_background, fx_factory.tex_id_glitch);
        // -------------------------------------------------------------------------------------------------------------

/*
        // TEST ---------------------------------------------------------------------------------------------------
        Program program_test;
        // Choose undefined of classic program
        if (fx_factory.frag_renders[0] & FX::FragRender::UNDEFINED)
            program_test.program_id = program_undefined.program_id;
        else
            program_test.program_id = program_classic.program_id;
        glUseProgram(program_test.program_id);
        // Set classic uniforms
        set_uniforms(program_test, window_w, window_h, total_time, delta_time);
        // set FX
        program_test.set_int("FXVertex", fx_factory.vertex_renders[0]);
        program_test.set_int("FXFrag", fx_factory.frag_renders[0]);
        program_test.set_int("factory_level_render", fx_factory.factory_level_render);
        // set Model matrix
        model_mat = glm::mat4(1.f);
        model_mat = glm::translate(model_mat, glm::vec3(-5.f, -3.f, 18.f));
        model_mat = glm::scale(model_mat, glm::vec3(0.1, 0.1, 0.1));
        model_mat = glm::rotate(model_mat, glm::radians(180.f), glm::vec3(0.f, 1.f, 0.f));
        program_test.set_mat4("model", model_mat);
        // Draw
        test.draw(program_test, fx_factory.tex_id_glitch);
        // -------------------------------------------------------------------------------------------------------------
*/


        // draw a quad with the framebuffer color texture
        glBindFramebuffer(GL_FRAMEBUFFER, 0); // bind back to default framebuffer
        glDisable(GL_DEPTH_TEST);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);


        // SCREEN ------------------------------------------------------------------------------------------------------
        Program program_screen;
        // Choose undefined of classic program
        if (fx_factory.frag_screen & FX::FragScreen::SCREEN_UNDEFINED)
            program_screen.program_id = program_screen_undefined.program_id;
        else
            program_screen.program_id = program_screen_classic.program_id;
        glUseProgram(program_screen.program_id);
        // Set classic uniforms
        set_uniforms(program_screen, window_w, window_h, total_time, delta_time);
        program_screen.set_int("screen_texture", 0);
        // set FX
        program_screen.set_int("FXFrag", fx_factory.frag_screen);
        program_screen.set_int("factory_level_screen", fx_factory.factory_level_screen);
        // Draw
        screen.draw();
        // -------------------------------------------------------------------------------------------------------------




        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }


    // glfw: terminate, clearing all previously allocated GLFW resources.
    // ------------------------------------------------------------------
    //glDeleteVertexArrays(1, &quadVAO);
    //glDeleteBuffers(1, &quadVBO);
    glfwTerminate();

    return 0;
}