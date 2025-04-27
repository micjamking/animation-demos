/* =========================================================================
   Minimal class-based WebGL setup
   ========================================================================= */

/**
 * Utility class that compiles + links a vertex/fragment pair and lets you
 * set uniforms with ergonomic helpers.
 */
class ShaderProgram {
  /** @param {WebGLRenderingContext} gl */
  constructor(gl, vertexSrc, fragmentSrc) {
    this.gl = gl;
    this.handle = this.#link(vertexSrc, fragmentSrc);
    this.uniformCache = new Map();
  }

  use() {
    this.gl.useProgram(this.handle);
  }

  /** @param {string} name */
  uniformLocation(name) {
    if (!this.uniformCache.has(name)) {
      this.uniformCache.set(name, this.gl.getUniformLocation(this.handle, name));
    }
    return this.uniformCache.get(name);
  }

  set1f(name, v) { this.gl.uniform1f(this.uniformLocation(name), v); }

  // ---------- private ------------------------------------------------------
  #compile(type, source) {
    const { gl } = this;
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      throw new Error(gl.getShaderInfoLog(shader));
    }
    return shader;
  }

  #link(vsrc, fsrc) {
    const { gl } = this;
    const program = gl.createProgram();
    gl.attachShader(program, this.#compile(gl.VERTEX_SHADER, vsrc));
    gl.attachShader(program, this.#compile(gl.FRAGMENT_SHADER, fsrc));
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      throw new Error(gl.getProgramInfoLog(program));
    }
    return program;
  }
}

/**
 * Creates a full-screen quad once, handles resize & animation loop.
 */
class ShaderApp {
  /**
   * @param {HTMLCanvasElement} canvas
   * @param {{ vertex:string, fragment:string }} src
   */
  constructor(canvas, src) {
    this.gl = canvas.getContext('webgl');
    if (!this.gl) throw new Error('WebGL not supported');

    // Build shader program
    this.prog = new ShaderProgram(this.gl, src.vertex, src.fragment);
    this.#initQuad();

    // Resize observer for DPR-aware canvases
    const resize = () => {
      const { clientWidth: w, clientHeight: h } = canvas;
      canvas.width = w * devicePixelRatio;
      canvas.height = h * devicePixelRatio;
      this.gl.viewport(0, 0, canvas.width, canvas.height);
    };
    new ResizeObserver(resize).observe(canvas);
    resize();

    requestAnimationFrame(this.#render.bind(this));
  }

  #initQuad() {
    const { gl } = this;

    const vertices = new Float32Array([
      -1, -1,  1, -1,  -1, 1,  1, 1   // two-triangle strip
    ]);

    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    const posLoc = gl.getAttribLocation(this.prog.handle, 'position');
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);
  }

  #render(timeMs) {
    const { gl, prog } = this;
    prog.use();
    prog.set1f('u_time', timeMs * 0.001);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(this.#render.bind(this));
  }
}

/* =========================================================================
   Shader sources (inline template strings for portability)
   ========================================================================= */

const VERT_SRC = /* glsl */`
  attribute vec2 position;
  void main() {
    gl_Position = vec4(position, 0.0, 1.0);
  }
`;

const FRAG_SRC = /* glsl */`
  precision mediump float;
  uniform float u_time;
  void main() {
    vec2 uv = gl_FragCoord.xy / vec2(${innerWidth.toFixed(1)},
                                     ${innerHeight.toFixed(1)});
    vec3 col = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0.0, 2.0, 4.0));
    gl_FragColor = vec4(col, 1.0);
  }
`;

/* =========================================================================
   Kick things off
   ========================================================================= */
console.log('Running ShaderApp...');
new ShaderApp(document.querySelector('canvas'), {
  vertex: VERT_SRC,
  fragment: FRAG_SRC
});
