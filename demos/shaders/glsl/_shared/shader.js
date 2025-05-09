/* =========================================================================
   Minimal class-based WebGL setup
   ========================================================================= */

/**
 * Utility class that compiles + links a vertex/fragment pair and lets you
 * set uniforms with ergonomic helpers.
 */
export class ShaderProgram {
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
  set2f(name, x, y) { this.gl.uniform2f(this.uniformLocation(name), x, y); }

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
export class ShaderApp {
  /**
   * @param {HTMLCanvasElement} canvas
   * @param {{ vertex:string, fragment:string }} src
   */
  constructor(canvas, src) {
    console.log('Running WebGL canvas shader...');
    this.gl = canvas.getContext('webgl');
    if (!this.gl) throw new Error('WebGL not supported');

    this.canvasWidth = 0;
    this.canvasHeight = 0;
    this.mouseX = 0;
    this.mouseY = 0;

    // Build shader program
    this.prog = new ShaderProgram(this.gl, src.vertex, src.fragment);
    this.#initQuad();

    // Resize observer for DPR-aware canvases
    const resize = () => {
      const { clientWidth: w, clientHeight: h } = canvas;
      canvas.width = w * devicePixelRatio;
      canvas.height = h * devicePixelRatio;
      this.gl.viewport(0, 0, canvas.width, canvas.height);
      this.canvasWidth = canvas.width;
      this.canvasHeight = canvas.height;
    };
    new ResizeObserver(resize).observe(canvas);
    resize();

    requestAnimationFrame(this.#render.bind(this));

    window.addEventListener(('mousemove'), (evt) => {
      this.mouseX = evt.pageX;
      this.mouseY = evt.pageY;
    });
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
    prog.set2f('u_resolution', this.canvasWidth, this.canvasHeight );
    prog.set2f('u_mouse', this.mouseX, this.mouseY );
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(this.#render.bind(this));
  }
}
