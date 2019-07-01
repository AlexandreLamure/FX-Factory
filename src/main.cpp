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

    Program program("../shaders/vertex/basic.glsl", "../shaders/fragment/basic.glsl");
    Program screen_program("../shaders/vertex/screen/basic.glsl", "../shaders/fragment/screen/distortion.glsl");

    Model samus("../resources/varia-suit/DolBarriersuit.obj");
    //Model classroom("../resources/animeclassroom/anime school.obj");
    Model background("../resources/varia-suit/background.obj");

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
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram(program.program_id);

        // set uniforms
        program.set_float("total_time", total_time);
        program.set_float("delta_time", delta_time);
        program.set_vec2("resolution", window_w, window_h);
        // set random
        program.set_int("rand", std::rand() % 100);
        // set lights
        program.set_vec3("ambient_light_color", 0.1f, 0.1f, 0.1f);
        program.set_vec3("light1_color", 1.0f, 1.0f, 1.0f);
        program.set_vec3("light1_position", -5.0f, 15.0f, 10.0f);
        program.set_vec3("light2_color", 0.8f, 0.0f + (cos(total_time)), 0.3f);
        program.set_vec3("light2_position", 5.0f, 0.0f, 2.0f);
        program.set_vec3("camera_pos", camera.pos);

        glm::mat4 view = glm::lookAt(camera.pos, camera.pos + camera.front, camera.up);
        program.set_mat4("view", view);

        glm::mat4 projection = glm::perspective(glm::radians(camera.fov), (float)window_w/(float)window_h, 0.1f, 100.0f);
        program.set_mat4("projection", projection);


        // samus
        glm::mat4 model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-0.3, -10.f, -3.f));
        model = glm::rotate(model, total_time * glm::radians(20.f), glm::vec3(0.f, 1.f, 0.f));
        program.set_mat4("model", model);
        samus.draw(program);

        // background
        model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-0.3, -10.f, -3.f));
        program.set_mat4("model", model);
        background.draw(program);

        // classroom
        /*model = glm::mat4(1.f);
        model = glm::translate(model, glm::vec3(-5.f, -3.f, 18.f));
        model = glm::rotate(model, glm::radians(180.f), glm::vec3(0.f, 1.f, 0.f));
        program.set_mat4("model", model);
        classroom.draw(program);*/



        // draw a quad with the framebuffer color texture
        glBindFramebuffer(GL_FRAMEBUFFER, 0); // bind back to default framebuffer
        glDisable(GL_DEPTH_TEST);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(screen_program.program_id);

        screen_program.set_int("screen_texture", 0);
        screen_program.set_float("total_time", total_time);
        screen_program.set_float("delta_time", delta_time);
        screen_program.set_vec2("resolution", window_w, window_h);
        screen_program.set_int("rand", std::rand() % 100);

        glBindVertexArray(quadVAO);
        glBindTexture(GL_TEXTURE_2D, texture_color_buffer);	// use the color attachment texture as the texture of the quad plane
        glDrawArrays(GL_TRIANGLES, 0, 6);


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