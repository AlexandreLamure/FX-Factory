# FX-Factory
The goal of this project is to allow the user to toggle many effects on a 3D scene, and to combine them to create new interesting effects.



## Build and run
```shell=sh
# Build
mkdir cmake-build && cd cmake-build
cmake ../ -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -j

# Run
./fx_factory
```


## Structure
* `lib/`: external libraries
* `resources/`: `OBJ` models
* `shaders/`: `GLSL` source code
* `src/`:`C++` source code and headers


## Libraries used
* GLAD (using OpenGL Loader-Generator):
    https://glad.dav1d.de
* GLFW3 (OpenGL window manager):
    https://github.com/glfw/glfw
* GLM (OpenGL mathematics):
    https://github.com/g-truc/glm
* Assimp (Asset import):
    https://github.com/assimp/assimp
* STB (Image loading):
    https://github.com/nothings/stb

## Results
**Youtube video:**
 https://youtu.be/0EzgnH4tP0o
 
 **Some examples:**
 
| ![](https://media.giphy.com/media/EuBYJrfQKkusvTQaUT/giphy.gif) | ![](https://media.giphy.com/media/WpPQYIq5Nlb8YeMKNs/giphy.gif) |
| -------- | -------- |
| ![](https://media.giphy.com/media/QR1pN9MwpROmwDSdUQ/giphy.gif) | ![](https://media.giphy.com/media/9dHuWVezErZgW3cK6j/giphy.gif) |
| ![](https://media.giphy.com/media/4B3V8N63f4ybCRRTZ3/giphy.gif) | ![](https://media.giphy.com/media/hbN5FbTdhJaZ7rhIFq/giphy.gif) |
| ![](https://media.giphy.com/media/2Yn2fxr3MssQro71Dr/giphy.gif) | ![](https://media.giphy.com/media/YyWHjGr9FCRNswSkl5/giphy.gif) |
| ![](https://media.giphy.com/media/nW1pSNGjp2ZvQ0ZUqK/giphy.gif) | ![](https://media.giphy.com/media/UHSzftE6srMrayYo0z/giphy.gif) |


 
## Commands
While the program is running, you can toggle the effects with your keyboard.
This FX management will be simplified in the future with a cool interface.

#### General commands
* `Z`, `Q`, `S`, `D`: moving
* `Space`/`Ctrl`: going up/down
* `1`: Select the main object
* `2`: Select the background object
* `Backspace`: Reset effects

#### Vertex effects:
* `0`: Texture shifting
* `9`: Water style normals

#### Fragment effects:
* `Y`: Texture moving
* `U`: Texture moving in a glitchy way
* `I`: Colorize
* `O`: RGB shifting
* `P`: Edge colorizing
* `G`: Toonify
* `O`: Horrorify
* `J`: Pixelize

#### Screen effects
The next effects are applied on the screen directly (using FBOs), not on the 3D models.
* `C`: RGB Shifting
* `V`: Patch glitch
* `N`: Old video effect
* `M`: Pixelize

#### Advanced effects
* `←`, `→`: Switch textures
* `↑`, `↓`: Combine effects
