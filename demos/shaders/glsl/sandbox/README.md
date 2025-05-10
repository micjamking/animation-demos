# GLSL Playground

## Concepts

### Composition (art & design)

 - [ ] Color multiple shapes with different colors in the same scene

 - [ ] Create a 2D illustrated scene using basic shapes and shape operations (add, subtract, include, exclude)

### Animation / transitions

 - [ ] A looping transition effect, ie. moving an object off screen, and then having it re-enter from the opposite side

 - [ ] Moving two objects in different directions

### 3D

- [ ] Create cube with lighting

### Aspect ratio and responsive scaling/positioning
Keeping the size and positioning of elements resolution independent is a matter of scaling the coordinates by the aspect ratio of the screen. This is done by multiplying the x coordinate by the aspect ratio (width / height) before passing it to the shader. The size of the polygon is also scaled by the aspect ratio to maintain its size relative to the screen dimensions. The position of the polygon is adjusted to be in the center of the screen, taking into account the aspect ratio. This ensures that the polygon appears in the same relative position and size on screens with different resolutions.