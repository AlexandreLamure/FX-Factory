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


Camera camera;

void mouse_callback(GLFWwindow* window, double xpos, double ypos)
{
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

    Program program("../shaders/vertex.glsl", "../shaders/fragment.glsl");


    Model obj1("../resources/varia-suit/DolBarriersuit.obj");
    //Model obj("../resources/varia-suit/dol2.obj");
    Model obj2("../resources/animeclassroom/anime school.obj");

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
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // draw our first triangle
        glUseProgram(program.program_id);

        // set uniforms
        program.set_float("total_time", total_time);
        program.set_float("delta_time", delta_time);
        // set random
        program.set_int("rand", std::rand() % 100);
        // set lights
        program.set_vec3("ambient_light_color", 0.1f, 0.1f, 0.1f);
        program.set_vec3("light1_color", 1.0f, 1.0f, 1.0f);
        program.set_vec3("light1_position", -5.0f, 15.0f, 10.0f);
        program.set_vec3("light2_color", 0.8f, 0.0f, 0.3f);
        program.set_vec3("light2_position", 5.0f, 0.0f, 2.0f);
        program.set_vec3("camera_pos", camera.pos);

        glm::mat4 view = glm::lookAt(camera.pos, camera.pos + camera.front, camera.up);
        program.set_mat4("view", view);

        glm::mat4 projection = glm::perspective(glm::radians(camera.fov), (float)window_w/(float)window_h, 0.1f, 100.0f);
        program.set_mat4("projection", projection);


        // samus
        glm::mat4 model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-0.3, -9.f, 0.f));
        model = glm::rotate(model, total_time * glm::radians(20.f), glm::vec3(0.f, 1.f, 0.f));
        program.set_mat4("model", model);
        obj1.draw(program);

        // background
        model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-5.f, -3.f, 18.f));
        model = glm::rotate(model, glm::radians(180.f), glm::vec3(0.f, 1.f, 0.f));
        program.set_mat4("model", model);
        obj2.draw(program);

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