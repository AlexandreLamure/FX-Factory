cmake_minimum_required(VERSION 3.13)
project(fx_factory)

set(CMAKE_CXX_STANDARD 17)

add_executable(fx_factory
               lib/glad/src/glad.c
               src/init.cc src/init.hh
               src/mesh.cc src/mesh.hh
               src/program.cc src/program.hh
               src/model.cc src/model.hh
               src/camera.cc src/camera.hh
               src/fx-factory.hh src/fx-factory.cc
               src/main.cc src/screen.cc src/screen.h)

#OpenGL
find_package(OpenGL REQUIRED)

# GLFW
find_package(PkgConfig REQUIRED)
pkg_search_module(GLFW REQUIRED glfw3)
set(GLFW_LIBRARIES_FIX "-lX11 -lpthread") # should be already included in GLFW_LIBRARIES

# GLAD
add_library(GLAD lib/glad/src/glad.c)
target_include_directories(GLAD PRIVATE lib/glad/include)
target_include_directories(fx_factory PRIVATE lib/glad/include)

# ASSIMP
find_package(assimp REQUIRED)


include_directories(${OPENGL_INCLUDE_DIRS} ${GLFW_INCLUDE_DIRS})

target_link_libraries(fx_factory ${OPENGL_LIBRARIES} ${GLFW_LIBRARIES} ${GLFW_LIBRARIES_FIX} GLAD ${CMAKE_DL_LIBS} assimp)