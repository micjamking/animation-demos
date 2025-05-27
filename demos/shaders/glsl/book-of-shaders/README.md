# Book of Shaders - Dev Notes

[https://thebookofshaders.com/00/](https://thebookofshaders.com/00/)

> You can think of \[shaders\] as the equivalent of Gutenberg's press for graphics

---

## 1 · The GPU pipeline

```
JavaScript (CPU)              GPU
┌──────────────┐  commands   ┌────────────────────────┐
│ your JS loop ├───────────►│  vertex shader (VS)     │ runs once per vertex
└──────────────┘             └────────┬───────────────┘
                                       ▼
                               primitive assembly
                                       ▼
                               rasterizer (creates pixels)
                                       ▼
                              ┌────────┴───────────────┐
                              │  fragment shader (FS)  │ runs once per pixel
                              └────────────────────────┘
                                       ▼
                                final framebuffer
```

* **Vertex shader**: transforms each corner of your geometry (position, normals…) into clip-space.  
* **Fragment shader**: computes the color of every pixel the primitive covers.  

A **shader program** is simply *those two tiny GLSL functions*, compiled to GPU machine code and stored in VRAM.  
The only way to *run* the program is to issue a **draw call** (`gl.drawArrays`) from JS; the GPU then launches **thousands of parallel shader invocations**.

---

## 2 · Structure: ShaderProgram vs ShaderApp

| Concern | Class | What it owns |
|---------|-------|--------------|
| **“What does the GPU need so it can execute my GLSL?”**<br>*(compile, link, look-up uniforms, re-use across frames)* | `ShaderProgram` | - Compiles vertex + fragment source once.<br>- Caches uniform/attribute locations.<br>- Exposes helpers (`set1f`, etc.). |
| **“What does my *application* need around that program?”**<br>*(canvas, resize, vertex buffers, animation loop)* | `ShaderApp` | - Creates WebGL context.<br>- Allocates a full-screen quad once.<br>- Updates time uniform each frame.<br>- Handles device-pixel-ratio resize.<br>- Owns the render loop. |

> If you picture WebGL as **“GPU-as-a-function”**, `ShaderProgram` is that pure function, while `ShaderApp` is the *caller* that provides inputs every frame.

You could merge them, but separating keeps each responsibility tiny and reusable:

```text
Another demo?      Just new ShaderProgram(gl, vSrc2, fSrc2)
Different canvas?  Just new ShaderApp(canvas2, { vertex, fragment })
```

---

## 3 · Line-by-line walkthrough

### ShaderProgram

```js
const vs = gl.createShader(gl.VERTEX_SHADER)
// 1. Create empty GPU object for a vertex shader.
gl.shaderSource(vs, vertexSrc)
// 2. Copy your GLSL string into it.
gl.compileShader(vs)
// 3. ask driver to compile → SPIR-V / machine instrs.

... same for fs (fragment shader) ...

gl.createProgram(); gl.attachShader(); gl.linkProgram();
// 4. Link VS+FS into a complete pipeline stage.
//    Now the GPU sees them as one “program”.
```

*Uniform helper*

```js
uniformCache.set(name, gl.getUniformLocation(this.handle, name))
// expensive lookup done once; later frames just reuse.
```

### ShaderApp

```js
const gl = canvas.getContext('webgl')
// WebGL context = door to the GPU.

this.prog = new ShaderProgram(gl, VERT_SRC, FRAG_SRC)
this.#initQuad()
// Builds a VBO with 4 vertices (-1..1) that cover the screen.

requestAnimationFrame(this.#render.bind(this))
// 60×/s browser calls render → GPU draws current frame.
```

```js
#render(timeMs){
  this.prog.use()                 // tell GL “next calls use this program”
  this.prog.set1f('u_time', timeMs)    // push changing uniform
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4) // ↙ GPU invocations cascade
}
```

Inside the **fragment shader** (`FRAG_SRC`):

```glsl
vec2 uv = gl_FragCoord.xy / resolution;
float color = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0,2,4));
gl_FragColor = vec4(color,1.0);
```

For every screen pixel, the GPU:

1. Computes normalized coordinates `uv`.
2. Sines them with time.
3. Emits an RGB color.

No loops, no branches in JS—the GPU parallelizes it all.

---

## 4 · How this differs from Canvas 2D

| Canvas 2D (`ctx.fillRect`) | WebGL shaders (`gl.drawArrays`) |
|---------------------------|---------------------------------|
| CPU paints pixel rows serially. | GPU executes thousands of fragments simultaneously. |
| State kept in JS; every shape re-sent per frame. | Geometry lives in VRAM; JS just issues a tiny draw command. |
| Great for immediate-mode drawings & text. | Mandatory for anything that needs GPU parallelism: complex fragments, massive particle fields, real-time 3-D. |

Think of WebGL as **a push constant + shader identifier**; the GPU then crunches in the background while your JS thread is already free to prepare the next frame.

---

### TL;DR mental model

1. **Shaders = mini parallel functions living on the GPU.**  
2. **`ShaderProgram` = “compile & remember my GPU function.”**  
3. **`ShaderApp` = “every frame: set new inputs, invoke the function.”**
