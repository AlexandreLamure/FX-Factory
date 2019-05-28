#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <cmath>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "init.hh"
#include "program.hh"
#include "model.hh"


void process_input(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}


int main()
{
    int window_w = 800;
    int window_h = 600;
    float total_time = 0.f;
    float delta_time = 0.f;
    float last_time = 0.f;

    GLFWwindow *window = Init::init_all(window_w, window_h);

    Program program;
    program.build("../shaders/vertex.glsl", "../shaders/fragment.glsl");


    //Model obj("../resources/varia-suit/DolBarriersuit.obj");
    Model obj("../resources/crysis-nano-suit-2/nanosuit.obj");
    //Model obj("../resources/cube/cube.obj");


    // main loop
    while(!glfwWindowShouldClose(window))
    {
        // update delta_time
        total_time = glfwGetTime();
        delta_time = total_time - last_time;
        last_time = total_time;

        // input
        process_input(window);

        // render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // draw our first triangle
        glUseProgram(program.program_id);

        // set uniforms
        program.set_float("total_time", total_time);
        program.set_float("delta_time", delta_time);

        glm::mat4 model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-0.3, -8.f, 0.f));
        model = glm::rotate(model, total_time * glm::radians(20.f), glm::vec3(0.f, 1.f, 0.f));
        //model = glm::scale(model, glm::vec3(0.1f, 0.1f, 0.1f));
        program.set_mat4("model", model);

        glm::mat4 view = glm::mat4(1.0f);
        view = glm::translate(view, glm::vec3(0.0f, 0.0f, -25.0f));
        program.set_mat4("view", view);

        glm::mat4 projection = glm::perspective(glm::radians(45.0f), (float)window_w/(float)window_h, 0.1f, 100.0f);
        program.set_mat4("projection", projection);


        obj.draw(program);


        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }


    // glfw: terminate, clearing all previously allocated GLFW resources.
    // ------------------------------------------------------------------
    glfwTerminate();

    return 0;
}