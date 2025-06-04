# 🎓 Book of Shaders - Dev Notes

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

---

# Web Graphics APIs

## 🎨 1. Canvas 2D API

### 🔧 What it is:

* A **2D immediate-mode drawing API**.
* You draw using methods like `fillRect`, `drawImage`, and `getImageData`.
* Raster-based: no GPU acceleration beyond compositing.

### ✅ Best For:

* 2D games and UI elements (e.g., tile maps, HUDs)
* Data visualization (e.g., simple charts, sparklines)
* Static or non-performant procedural graphics
* Image manipulation and pixel-based operations

### ❌ Limitations:

* Not hardware-accelerated in the way WebGL is
* Performance bottlenecks for complex scenes or animations
* No shaders or 3D
* No GPU parallelism or offloading

### 🧠 Use it when:

* You need a simple, lightweight solution
* You’re building 2D drawing tools, sprite-based games, or doing quick prototyping

---

## 🧱 2. WebGL / WebGL 2.0

### 🔧 What it is:

* A **JavaScript binding to OpenGL ES**, giving access to the GPU
* Built around **shader programming** (GLSL)
* You must manage buffers, shaders, textures, state — manually

### ✅ Best For:

* Real-time 2D/3D graphics and animation
* Shader-based generative art and effects
* Complex data visualizations (e.g., geospatial rendering, particles)
* 3D engines (Three.js, Babylon.js) are built on top of WebGL

### ❌ Limitations:

* Verbose and stateful (requires deep understanding of GL concepts)
* No compute shaders — everything must be done via vertex/fragment shaders
* Limited flexibility compared to newer APIs like WebGPU
* WebGL 2.0 adoption is not universal

### 🧠 Use it when:

* You need high-performance rendering
* You want full control over GPU shaders
* You're building your own rendering engine or customizing an existing one
* You're doing creative coding or interactive art

---

## 🚀 3. WebGPU (next-gen)

### 🔧 What it is:

* The **modern replacement for WebGL**, built on top of Vulkan/Metal/DX12
* Supports **compute shaders**, **bind groups**, **async pipelines**, and more modern GPU capabilities

### ✅ Best For:

* GPGPU workflows (image processing, physics simulations, AI inference)
* Highly parallel compute-intensive tasks
* Cutting-edge rendering engines or research
* Games or 3D scenes needing better performance than WebGL can offer

### ❌ Limitations:

* Still not universally supported (as of mid-2025, mainly Chrome/Canary/Edge + flags)
* More complex setup than WebGL
* Fewer learning resources
* Overkill for simple use cases

### 🧠 Use it when:

* You need raw GPU power: physics engines, AI, ray marching, high-res particle fields
* You want to future-proof your graphics pipeline
* You're building a next-gen renderer or tool

---

## 🧩 Side-by-Side Comparison Table

| Feature / Use Case  | Canvas API        | WebGL / WebGL2          | WebGPU                           |
| ------------------- | ----------------- | ----------------------- | -------------------------------- |
| **API Type**        | Immediate-mode 2D | Retained-mode 3D        | Modern GPU abstraction           |
| **Performance**     | Low               | High                    | Very High                        |
| **Shader Access**   | ❌                 | ✅ (GLSL)                | ✅ (WGSL, compute too)            |
| **3D Support**      | ❌                 | ✅                       | ✅                                |
| **Compute Shaders** | ❌                 | ❌                       | ✅                                |
| **Ease of Use**     | ✅                 | ⚠️ Steep learning curve | ⚠️ Very steep curve              |
| **Best For**        | 2D art, image ops | Real-time 3D, shaders   | Advanced GPGPU, modern rendering |
| **Support**         | Universal         | Universal (mostly)      | Limited (but growing)            |
| **Tooling**         | Simple editors    | ShaderToy, Three.js     | Babylon.js, WGPU.js              |

---

## 🧠 TL;DR: Which One Should You Use?

| Problem / Goal                                  | Use This              |
| ----------------------------------------------- | --------------------- |
| Draw 2D shapes or charts                        | **Canvas API**        |
| Build a shader-driven animation or visual       | **WebGL**             |
| Create real-time 3D visuals for the web         | **WebGL or Three.js** |
| Perform parallel GPU processing (e.g. physics)  | **WebGPU**            |
| Prototype generative art w/ full-screen shaders | **WebGL**             |
| Explore the GPU as a creative medium            | **WebGPU (future)**   |

---

Would you like a starter template showing the same generative visual rendered in **Canvas**, **WebGL**, and **WebGPU** for comparison? That’s a great way to see their strengths side-by-side.

---

# Rendering Engines on the Web

## 🔧 What is a "Rendering Engine"?

At its core, a **rendering engine** is a system that takes a **scene** (geometry, materials, lights, camera) and turns it into **pixels on the screen**.

### ✅ Responsibilities of a Rendering Engine

* **Scene Management**: Maintain a tree or graph of renderable objects
* **Transformations**: Apply matrix math to place objects in world space
* **Camera System**: Handle view/projection matrices
* **Material System**: Shaders, textures, blending modes
* **Lighting**: Manage how objects interact with light (Phong, PBR, etc.)
* **Draw Calls**: Issue `gl.drawArrays` or `gl.drawElements` with correct state
* **Optimizations**: Frustum culling, batching, LOD, shadow maps, etc.

> In **Three.js or Pixi.js**, all of the above is abstracted into clean APIs. You describe the *what*, it handles the *how*.

---

## 🌐 Web Graphics Rendering Engines

If you're building **custom WebGL/WebGPU apps**, **generative visuals**, **interactive installations**, or **real-time 3D experiences**, you're working with or building parts of a rendering engine.

While most frontend devs don’t go that deep, anyone doing **graphics programming** on the web—especially shader artists, creative coders, and interactive designers—eventually builds or extends rendering pipelines.

---

## ✅ Minimal Canvas 2D Rendering Engine

A **minimal rendering engine** using the **Canvas API** establishes a basic framework to:

1. Set up the 2D drawing context
2. Create a draw loop
3. Manage time and possibly input
4. Provide a structure for adding renderable objects

---

```js
class CanvasEngine {
  /**
   * @param {HTMLCanvasElement} canvas 
   * @param {(ctx: CanvasRenderingContext2D, time: number) => void} renderFn 
   */
  constructor(canvas, renderFn) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.renderFn = renderFn;
    this.resize();
    window.addEventListener('resize', () => this.resize());
    requestAnimationFrame(this.loop.bind(this));
  }

  resize() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }

  loop(time) {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.renderFn(this.ctx, time * 0.001);
    requestAnimationFrame(this.loop.bind(this));
  }
}

// Initialize the engine with a draw function
new CanvasEngine(document.getElementById('canvas'), (ctx, t) => {
  ctx.fillStyle = 'black';
  ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

  ctx.fillStyle = 'white';
  ctx.beginPath();
  const x = ctx.canvas.width / 2 + Math.sin(t) * 100;
  const y = ctx.canvas.height / 2;
  ctx.arc(x, y, 50, 0, Math.PI * 2);
  ctx.fill();
});
```

## 🧠 Features This Covers

* ✅ Canvas context setup
* ✅ Resize handling
* ✅ Time-based animation
* ✅ Render loop
* ✅ Encapsulated engine logic

---

## 🧰 Minimal WebGL Rendering Engine


### 1. **Context Setup**

```js
const canvas = document.querySelector('canvas');
const gl = canvas.getContext('webgl');
```

### 2. **Shader Compilation**

* Vertex + Fragment shader compilation
* Link into a program
* Upload to GPU

### 3. **Buffer Setup**

* Geometry (positions, normals, uvs)
* Create VBOs (Vertex Buffer Objects)
* Upload attribute data
* Bind index buffers (optional)

### 4. **Render Loop**

```js
function render() {
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  gl.useProgram(program);
  gl.bindBuffer(...);
  gl.drawArrays(...);
  requestAnimationFrame(render);
}
render();
```

### 5. **Uniforms and State**

* Handle `u_time`, `u_resolution`, `u_cameraMatrix`
* Set blend modes, depth testing
* Pass matrices for camera/view/projection

---

## ✨ Minimal Rendering Pipeline (Diagram)

```
Scene Data (geometry, materials, transforms)
        ↓
CPU: JS transforms → matrices, uniforms
        ↓
GPU: WebGL/GLSL shaders
        ↓
Vertex Shader → Rasterizer → Fragment Shader
        ↓
Framebuffer (the screen)
```

If you’re building this from scratch, you're implementing the **rendering pipeline** manually — each WebGL call is a step in that pipeline.

---

## 🎨 Comparing to Three.js or Pixi.js

| Feature                  | Custom WebGL              | Three.js / Pixi.js          |
| ------------------------ | ------------------------- | --------------------------- |
| Setup                    | Manual                    | Abstracted                  |
| Shaders                  | Write your own            | Built-in materials + custom |
| Camera & Transforms      | Manual matrix math        | Easy, baked in              |
| Scene Graph              | You implement it          | Comes for free              |
| Performance Optimization | Up to you                 | Handles culling, batching   |
| Use Case                 | Artistic control, shaders | Rapid prototyping, scale    |

> Think of Three.js like a creative director: it choreographs your scene.
> A custom WebGL engine is like DIY stage building: you hammer each nail.

---

## 👩‍💻 In the Industry

### When people say “rendering engine” in:

* **Game dev**: Full 3D renderer (Unreal, Unity, or custom)
* **Film/CG**: Physically-based offline renderers (Arnold, Renderman)
* **Web**: Could mean:

  * Custom WebGL/WebGPU engines (like yours)
  * Custom rendering layers inside a canvas/web app
  * Extending engines like Three.js with custom passes or materials

### In practice, on the web:

* You might build a **modular rendering engine** to manage:

  * Multiple render passes (e.g. post-processing FX)
  * Framebuffers/textures (for feedback loops)
  * Scene graphs, shaders, and transitions

---

## 🛠️ TL;DR

> A "web graphics rendering engine" is a system you create (or extend) to manage everything from **scene setup → shaders → draw calls → final image**, especially when using raw WebGL/WebGPU.

You don’t *need* to build one—but if you do, you’ll understand **how every pixel got there**.

---

# 🎓 **Framebuffers, Textures, and Post-Processing in Web Graphics**

---

## 🧠 **Course Objective**

By the end of this module, you will:

* Understand how to render **to** and **from** textures using framebuffers.
* Learn how to **apply shaders** to existing media (image, video, 3D).
* Understand the distinction between **procedural fragment shading** and **post-processing** workflows.
* Build a framework for feedback effects (e.g. trails, echoes, distortion over time).

---

## 🔁 **1. Shaders as Procedural Canvases**

**You've already mastered this**:

* A full-screen triangle/quad.
* Fragment shader treats each pixel as a "blank slate."
* You control color, shape, animation via math (SDFs, noise, etc.).

### Example:

```glsl
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(sin(u_time + uv.x * 10.0));
    gl_FragColor = vec4(color, 1.0);
}
```

This is the purest form of **generative shader art**, often built in isolation (like in Shadertoy).

---

## 🧩 **2. Using Shaders to Process Textures (Image, Video, 3D Scene)**

### 🔶 How it works:

You pass a `sampler2D` uniform to the shader:

```glsl
uniform sampler2D u_texture;
```

Then sample it using UV coordinates:

```glsl
vec4 texColor = texture2D(u_texture, uv);
```

This technique is core to:

* Image filters
* Video effects
* Post-processing 3D renders

### ✅ Key concepts:

* You’re no longer “painting from scratch.”
* The shader’s job becomes “**how should I change this pixel?**”
* This is called **image-based shading**.

---

## 🎯 **3. What is a Framebuffer (FBO)?**

### 📦 Definition:

A **Framebuffer Object (FBO)** in WebGL is an off-screen surface you render into. Instead of drawing directly to the screen, you draw to a texture, and then later draw *that* texture to the screen (often with effects applied).

### 🔧 Usage:

* Set up a framebuffer
* Attach a texture to it (your “render target”)
* Render scene → texture (FBO)
* Use that texture in another shader for post-processing

### 📘 WebGL API Analogy:

```js
gl.bindFramebuffer(gl.FRAMEBUFFER, myFBO);
renderScene(); // draw scene into texture

gl.bindFramebuffer(gl.FRAMEBUFFER, null);
postProcess(myFBO.texture); // use texture as input
```

### 🔄 Benefits:

* Enables **multi-pass rendering**
* Essential for **screen-wide FX**
* Basis for **feedback** and **accumulation** effects

---

## 🎥 **4. Input Media Types You Can Process**

### 🖼️ Static Images

* Load with `new Image()`, upload via `gl.texImage2D`
* Sample in shader for glitch, pixelation, color grading

### 📹 HTML Video

* Use `<video>` element, update texture per frame
* Real-time VJ effects, pixel sorting, slit-scanning

### 🔺 3D Scene

* Render geometry (meshes, models) to texture
* Then post-process like bloom, DOF, CRT

---

## 🎬 **5. Post-Processing Pipelines**

### 🔂 Typical Pipeline:

```
1. Scene (3D or 2D) rendered to texture (via framebuffer)
2. Fullscreen quad draws that texture
3. Post-processing shader manipulates the texture:
   - Blur, distort, RGB shift, bloom, CRT curvature, scanlines
```

This is conceptually like applying Photoshop filters in a layered system — but in real-time, on the GPU.

### ✅ Real Examples:

* Game engines use this for SSAO, bloom, motion blur
* VJs use this for effects on live webcam/video streams
* Artists use this to stylize generative work or mix media types

---

## ♻️ **6. Feedback Effects & Accumulation**

### 🔁 Core Idea:

Render the previous frame into a texture, use it as input on the next frame.

This enables:

* Trails
* Decay
* Afterimages
* Buffer-based generative loops

### 🔄 Loop:

```glsl
vec4 prevFrame = texture2D(u_prevFrame, uv);
gl_FragColor = mix(currentEffect, prevFrame, 0.9);
```

### 🧠 Needs:

* Double-buffering (ping-pong technique)
* Multiple framebuffers swapping each frame

---

## 🔍 **7. Conceptual Comparison: Painting vs Filtering**

| Concept | Fragment Shader Canvas | Texture/Post FX Shader |
| ------- | ---------------------- | ---------------------- |
| Input   | None (just math)       | Texture (image/video)  |
| Output  | Full procedural image  | Modified image         |
| Uses    | SDFs, math art, loops  | Glitch, RGB shift, FX  |
| Flex    | High pixel freedom     | High aesthetic control |

---

## 📚 Recommended Study Resources

### 🎓 Books & Tutorials

* **The Book of Shaders** ([https://thebookofshaders.com](https://thebookofshaders.com))
* **WebGL2 Fundamentals** by Gregg Tavares ([https://webgl2fundamentals.org](https://webgl2fundamentals.org))
* **Real-Time Rendering, 4th ed.** by Akenine-Möller et al.
* **ShaderToy Techniques** on inigoquilez.com

### 🎨 Tools to Learn From

* [ShaderToy](https://shadertoy.com)
* [glslViewer](https://github.com/patriciogonzalezvivo/glslViewer)
* [hydra.ojack.xyz](https://hydra.ojack.xyz/)
* [Three.js post-processing examples](https://threejs.org/examples/#webgl_postprocessing_unreal_bloom)

---

## 🎓 Assignments (Optional)

1. **Render a webcam feed to texture and apply glitch FX**
2. **Make a feedback loop trail using ping-pong FBOs**
3. **Apply a CRT + chromatic aberration shader over a 3D rotating cube**
4. **Implement post-FX in TouchDesigner using feedback and GLSL TOPs**
5. **Build your own modular post-processing chain using raw WebGL**

---

Let me know when you're ready to move on to **Module 3: Multi-pass pipelines, ping-pong buffers, and advanced motion-based FX**, or if you want a working starter template with framebuffer chaining and modular shader inputs.
