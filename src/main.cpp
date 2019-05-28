#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <cmath>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "init.hh"
#include "program.hh"
#include "model.hh"


void process_input(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}



int main() {

    int window_w = 800;
    int window_h = 600;
    float total_time = 0.f;
    float delta_time = 0.f;
    float last_time = 0.f;

    GLFWwindow *window = Init::init_all(window_w, window_h);

    Program program;
    program.build("../shaders/vertex.glsl", "../shaders/fragment.glsl");


    Model model("../resources/varia-suit/DolBarriersuit.obj");
    //Model model("../resources/cube/cube.obj");


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

        glm::mat4 m = glm::mat4(1.f);
        m = glm::translate(m, glm::vec3(-0.5, 0.f, 0.f));
        //m = glm::rotate(m, glm::radians(90.f), glm::vec3(0.f, 0.f, 1.f));
        m = glm::scale(m, glm::vec3(0.05f, 0.05f, 0.05f));
        program.set_mat4("m", m);


        model.draw(program);


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