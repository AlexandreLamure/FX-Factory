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
 
<a href="https://i.imgur.com/qzIlRpS.jpg"><img src="https://i.imgur.com/qzIlRpS.jpg" width="380"/></a> <a href="https://i.imgur.com/dChfb7D.jpg"><img src="https://i.imgur.com/dChfb7D.jpg" width="380"/></a>
<a href="https://i.imgur.com/zlOkwuV.jpg"><img src="https://i.imgur.com/zlOkwuV.jpg" width="380"/></a> <a href="https://i.imgur.com/kCmlAbH.jpg"><img src="https://i.imgur.com/kCmlAbH.jpg" width="380"/></a>
<a href="https://i.imgur.com/dTDITVa.jpg"><img src="https://i.imgur.com/dTDITVa.jpg" width="380"/></a> <a href="https://i.imgur.com/dEk8FcN.jpg"><img src="https://i.imgur.com/dEk8FcN.jpg" width="380"/></a>
<a href="https://i.imgur.com/GhQjKcZ.jpg"><img src="https://i.imgur.com/GhQjKcZ.jpg" width="380"/></a> <a href="https://i.imgur.com/VNqbOhc.jpg"><img src="https://i.imgur.com/VNqbOhc.jpg" width="380"/></a>
<a href="https://i.imgur.com/oe7wcBJ.jpg"><img src="https://i.imgur.com/oe7wcBJ.jpg" width="380"/></a> <a href="https://i.imgur.com/BpAt63i.jpg"><img src="https://i.imgur.com/BpAt63i.jpg" width="380"/></a>
<a href="https://i.imgur.com/iIrCDuh.jpg"><img src="https://i.imgur.com/iIrCDuh.jpg" width="380"/></a> <a href="https://i.imgur.com/noFMITX.jpg"><img src="https://i.imgur.com/noFMITX.jpg" width="380"/></a>
<a href="https://i.imgur.com/FSRbqkc.jpg"><img src="https://i.imgur.com/FSRbqkc.jpg" width="380"/></a> <a href="https://i.imgur.com/gAdD5Ry.jpg"><img src="https://i.imgur.com/gAdD5Ry.jpg" width="380"/></a>
<a href="https://i.imgur.com/jEXGkSX.jpg"><img src="https://i.imgur.com/jEXGkSX.jpg" width="380"/></a> <a href="https://i.imgur.com/WBr9lOK.jpg"><img src="https://i.imgur.com/WBr9lOK.jpg" width="380"/></a>

 
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
