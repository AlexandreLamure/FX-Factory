#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

void init_glfw()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
}

GLFWwindow *init_window(int width, int height)
{
    GLFWwindow* window = glfwCreateWindow(width, height, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return nullptr;
    }
    glfwMakeContextCurrent(window);
    return window;
}

bool init_glad()
{
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return false;
    }
    return true;
}

int main() {

    int window_w = 800;
    int window_h = 600;

    // init GLFW
    init_glfw();

    // init GLFW window
    GLFWwindow *window = init_window(window_w, window_h);
    if (!window)
        return 1;

    // init GLAD
    if (!init_glad())
        return 1;

    // tell the size of window to openGL
    glViewport(0, 0, window_w, window_h);

    // set resize callback
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // main loop
    while(!glfwWindowShouldClose(window))
    {
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // exit properly
    glfwTerminate();

    return 0;
}