cmake_minimum_required(VERSION 3.13)
project(openGL_Glitch)

set(CMAKE_CXX_STANDARD 17)

add_executable(openGL_Glitch src/main.cpp glad/src/glad.c)


#OpenGL
find_package(OpenGL REQUIRED)

# GLFW
find_package(PkgConfig REQUIRED)
pkg_search_module(GLFW REQUIRED glfw3)

# GLAD
add_library(GLAD glad/src/glad.c)
target_include_directories(GLAD PRIVATE glad/include)
target_include_directories(openGL_Glitch PRIVATE glad/include)


include_directories(${OPENGL_INCLUDE_DIRS} ${GLFW_INCLUDE_DIRS})

target_link_libraries(openGL_Glitch ${OPENGL_LIBRARIES} ${GLFW_LIBRARIES} GLAD ${CMAKE_DL_LIBS})