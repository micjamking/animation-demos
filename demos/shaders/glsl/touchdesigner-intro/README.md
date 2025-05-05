# TouchDesigner Intro to GLSL - Dev Notes

<!-- [https://thebookofshaders.com/00/](https://thebookofshaders.com/00/) -->

<!-- > You can think of \[shaders\] as the equivalent of Gutenberg's press for graphics -->

## 5.0 - Colors

The default pixel shader from a `GLSL TOP`:

```glsl
out vec4 fragColor;
main(){
  vec4 color = vec4(1.0);
  fragColor = TDOutputSwizzle(color);
}
```

In the above code, there are two important pieces:

```glsl
out vec4 fragColor;
```

This line defines an `out` (output) variable of type `vec4` (a vector containing 4 float values) called `fragColor`; this will be used as the output for our `main()` function.

```glsl
vec4 color = vec4(1.0);
```

This line creates a 4 channel color using a `vec4`. `vec4(1.0)` is shorthand and equivalent to `vec4(1.0, 1.0, 1.0, 1.0)`.

In pixel shaders, colors are defined as 4 channel float values, with the each value representing the corresponding channel from _rgba_ color space:

```glsl
vec4 color = vec4(
  1.0, // Red
  1.0, // Green
  1.0, // Blue
  1.0, // Alpha
)
```

Each color channel ranges from 0.0-1.0, comparable to the 0-255 range in CSS/JS. The above `vec4(1.0)` is equivalent to `rgba(255,255,255,1.0)` and should display a white screen.

![white screen](_screenshots\image-06.png "White screen")

```glsl
vec4 color = vec4(1.0, 0.0, 0.5, 1.0);
```

The above should result in a pink color, mixing 100% of the red channel and 50% of the blue channel:

![pink screen](_screenshots\image-07.png "Pink screen")


```glsl
vec4 color = vec4(1.0);
color.r = 0.2;
color.y = 0.8;
```

(See [0.5.1 Swizzling](#051---swizzling) below)

The above should result in a baby blue color, mixing 20% of the red channel and 80% of the green channel, and 100% of the blue channel:

![baby blue screen](_screenshots\image-08.png "Baby blue screen")


### 5.1 - Swizzlin'
The shorthand suffixes `.rgba`, `.xyzw`, and `.stpq` in GLSL are known as **swizzle masks** — they allow you to access or rearrange components of vector types (like `vec2`, `vec3`, `vec4`) using meaningful labels, depending on **context** or **semantic convention**.

Here’s what they map to and why you see them:

---

#### **Swizzle Mask Equivalents:**

| Meaning     | 2D Vectors    | 3D Vectors | 4D Vectors                                |
| ----------- | ------------- | ---------- | ----------------------------------------- |
| Coordinates | `.xy`, `.xyz` | `.xyzw`    | Used in position, direction, general math |
| Colors      | `.rg`, `.rgb` | `.rgba`    | Used in color operations                  |
| Texture UVs | `.st`, `.stp` | `.stpq`    | Used in texture coordinate operations     |

---

#### **Where `.stpq` comes from:**

* **`s`, `t`, `p`, `q`** were traditionally used in OpenGL for **texture coordinate axes**.
* So in GLSL, `.stpq` is a semantic alias for `.xyzw`, used **when dealing with texture coordinates** or sampling.

Example:

```glsl
vec4 texCoord = vec4(0.1, 0.2, 0.0, 1.0);
float u = texCoord.s; // same as texCoord.x
float v = texCoord.t; // same as texCoord.y
```

This allows more expressive, readable code depending on what the vector represents:

* `.xyzw` → general-purpose math (position, velocity, etc.)
* `.rgba` → color data
* `.stpq` → texture coordinates

## 6.0 - Step Function

**The Coordinate System**

When working in  GLSL, we want the same code to run with all kinds of image resolution... To achieve this, we can normalize our image space, ie scaling the horizontal and vertical coordinates to be contained in a 0.0 - 1.0 range.

_Normalized clip-space:_
```
 top-left        top-right
 (0.0, 1.0)—————(1.0, 1.0)
 |                       |
 |                       |
 |                       |
 |                       |
 |                       |
 |                       |
 |                       |
 |                       |
 (0.0, 0.0)—————(1.0, 0.0)
 bottom-left  bottom-right
```

In GLSL, we do this by defining a new variable as the ratio between the window relative coordinate values and the resolution of our canvas:

```glsl
vec2 st = glFragCoord.xy / uResolution;
```

TouchDesigner has a built in variable for this named `vUV`.

**Mapping Coordinates to Colors**

```glsl
vec4 color = vec4(vUV.x, 0.0, 0.0, 1.0);
```

This should result in a horizontal, black-to-red gradient since we are mapping our `x` coordinate values to our red channel.

![black to red gradient - horizontal](_screenshots\image-01.png "Black to Red Gradient - Horizontal")

```glsl
vec4 color = vec4(vUV.y, 0.0, 0.0, 1.0);
```

This should result in a vertical, black-to-red gradient since we are mapping our `y` coordinate values to our red channel.

![black to red gradient - vertical](_screenshots\image-02.png "Black to Red Gradient - Vertical")

```glsl
vec4 color = vec4(vUV.x, vUV.y, 0.0, 1.0);
```

This should result in a rastafarian, green-red-yellow gradient, mapping our `x` coordinate values to our red channel, and `y` to our green channel, with both channels mixing in the top right corner to make yellow.

![rasta gradient](_screenshots\image-03.png "Rasta Gradient")

**Colors with Step Function**

```glsl
vec4 color = vec4(step(0.5, vUV.x), 0.0, 0.0, 1.0);
```

The step function allows us to create shape by providing a threshold and mapping value. The above outputs a constant `0.0` value if the input value is less than the `0.5` threshold, or a constant `1.0` if the input value is equal to or greater than the threshold.

![black red split](_screenshots\image-04.png "Black Red Split")

```glsl
vec4 color = vec4(step(0.75, vUV.x), step(0.5, vUV.y), 0.0, 1.0);
```

We can combine multiple step functions to draw basic shapes with code.

![rasta flag](_screenshots\image-05.png "Rasta Flag")

## 7.0 - Drawing Circles

To draw circles, we use the `length` function in combination with the `step` function:

```glsl
float myCircle = step(0.2, length(vUV.xy));
vec4 color = vec4(myCircle, 0.0, 0.0, 1.0);
```

![black corner circle](_screenshots\image-09.png "Black corner circle")

### **What `length(vUV.xy)` Does**

This computes the **Euclidean distance** from the origin `(0.0, 0.0)` to the current UV coordinate — and that's exactly where the **Pythagorean Theorem** comes in.

If you think of `vUV.xy` as a 2D point `(x, y)`, the `length()` function does:

$$
\text{length}(vUV.xy) = \sqrt{x^2 + y^2}
$$

That’s literally the **distance from (0,0)** to `(x, y)` — the hypotenuse of a right triangle where the legs are `x` and `y`.

---

### **Why This Creates a Radial Shape**

As we move farther from `(0.0, 0.0)` (the bottom-left corner), the distance increases.

* At the bottom-left corner (0,0):

  $$
  \sqrt{0^2 + 0^2} = 0.0 \Rightarrow \text{black}
  $$
* At the top-right corner (1,1):

  $$
  \sqrt{1^2 + 1^2} = \sqrt{2} \approx 1.41 \Rightarrow \text{overshoots red > 1.0}
  $$

But **because the red channel only expects values between 0.0 and 1.0**, any result over 1.0 will get **clamped** (or wrapped, depending on how the shader is written or sampled).

So this code:

```glsl
vec4 color = vec4(length(vUV.xy), 0.0, 0.0, 1.0);
```

creates a radial red gradient that:

* **originates** from the **bottom-left corner (0,0)**, not bottom-right
* **increases** in intensity as the distance from (0,0) increases
* fades from black to red following a **circular (radial)** pattern

Adding `step(0.2, length(vUV.xy))` establishes a hard boundary, thereby creating a distinct circle shape.

**Centering the circle**

```glsl
float myCircle = step(0.2, length(vUV.xy - 0.5));
vec4 color = vec4(myCircle, 0.0, 0.0, 1.0);
```

Moving the circle is simply a matter of minusing the `x` and `y` coordinate of the target location from our normalized `x` and `y` pixel coordinates. In the above case, the center of the window is `(0.5, 0.5)`, so we can use the shorthand `vUV.xy - 0.5` to minus `0.5` from the current `x` and `y` values to move them to the center.

![black center circle](_screenshots\image-10.png "Black center circle")