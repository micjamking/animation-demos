/* =========================================================================
   Modular, Post-Processing-Ready WebGL Shader Engine (with media support)
   ========================================================================= */

export class ShaderProgram {
  constructor(gl, vertexSrc, fragmentSrc) {
    this.gl = gl;
    this.handle = this.#link(vertexSrc, fragmentSrc);
    this.uniformCache = new Map();
  }

  use() {
    this.gl.useProgram(this.handle);
  }

  uniformLocation(name) {
    if (!this.uniformCache.has(name)) {
      this.uniformCache.set(name, this.gl.getUniformLocation(this.handle, name));
    }
    return this.uniformCache.get(name);
  }

  set1f(name, v) { this.gl.uniform1f(this.uniformLocation(name), v); }
  set2f(name, x, y) { this.gl.uniform2f(this.uniformLocation(name), x, y); }
  set1i(name, i) { this.gl.uniform1i(this.uniformLocation(name), i); }

  #compile(type, source) {
    const shader = this.gl.createShader(type);
    this.gl.shaderSource(shader, source);
    this.gl.compileShader(shader);
    if (!this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS)) {
      throw new Error(this.gl.getShaderInfoLog(shader));
    }
    return shader;
  }

  #link(vsrc, fsrc) {
    const program = this.gl.createProgram();
    this.gl.attachShader(program, this.#compile(this.gl.VERTEX_SHADER, vsrc));
    this.gl.attachShader(program, this.#compile(this.gl.FRAGMENT_SHADER, fsrc));
    this.gl.linkProgram(program);
    if (!this.gl.getProgramParameter(program, this.gl.LINK_STATUS)) {
      throw new Error(this.gl.getProgramInfoLog(program));
    }
    return program;
  }
}

export class PostEffect {
  constructor(gl, program, width, height) {
    this.gl = gl;
    this.prog = program;
    this.tex = gl.createTexture();
    this.fbo = gl.createFramebuffer();

    gl.bindTexture(gl.TEXTURE_2D, this.tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    gl.bindFramebuffer(gl.FRAMEBUFFER, this.fbo);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this.tex, 0);
  }

  draw(inputTex, time, resolution, mouse, mediaTex = null) {
    const gl = this.gl;
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.fbo);
    gl.viewport(0, 0, resolution[0], resolution[1]);

    this.prog.use();
    this.prog.set1f('u_time', time);
    this.prog.set2f('u_resolution', resolution[0], resolution[1]);
    this.prog.set2f('u_mouse', mouse[0], mouse[1]);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, inputTex);
    this.prog.set1i('u_scene', 0);

    if (mediaTex) {
      gl.activeTexture(gl.TEXTURE1);
      gl.bindTexture(gl.TEXTURE_2D, mediaTex);
      this.prog.set1i('u_media', 1);
    }

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
}

export class ShaderApp {
  constructor(canvas, { vertex, scene, effects, mediaElement = null }) {
    this.gl = canvas.getContext('webgl2');
    if (!this.gl) throw new Error('WebGL not supported');

    this.canvas = canvas;
    this.vertexSrc = vertex;
    this.sceneSrc = scene;
    this.effectsSrc = effects || [];
    this.mediaElement = mediaElement;
    this.mouseX = 0;
    this.mouseY = 0;
    this.effects = [];

    this.#initGL();
    this.#initPrograms();
    this.#initBuffers();
    this.#initResize();
    this.#initMedia();
    requestAnimationFrame(this.#render.bind(this));
    window.addEventListener('mousemove', e => {
      this.mouseX = e.pageX;
      this.mouseY = e.pageY;
    });
  }

  #initGL() {
    const gl = this.gl;
    this.sceneFBO = this.#createFBO();
    this.ping = this.#createFBO();
    this.pong = this.#createFBO();
  }

  #createFBO() {
    const gl = this.gl;
    const tex = gl.createTexture();
    const fbo = gl.createFramebuffer();

    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.canvas.width, gl.canvas.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0);

    return { fbo, tex };
  }

  #initPrograms() {
    const gl = this.gl;
    this.sceneProg = new ShaderProgram(gl, this.vertexSrc, this.sceneSrc);
    this.effectProgs = this.effectsSrc.map(frag => new ShaderProgram(gl, this.vertexSrc, frag));
    this.effects = this.effectProgs.map(prog => new PostEffect(gl, prog, gl.canvas.width, gl.canvas.height));
  }

  #initBuffers() {
    const gl = this.gl;
    const vertices = new Float32Array([ -1, -1, 1, -1, -1, 1, 1, 1 ]);
    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    const posLoc = gl.getAttribLocation(this.sceneProg.handle, 'position');
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);
  }

  #initResize() {
    const gl = this.gl;
    const resize = () => {
      const { clientWidth: w, clientHeight: h } = this.canvas;
      this.canvas.width = w * devicePixelRatio;
      this.canvas.height = h * devicePixelRatio;
      gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    };
    new ResizeObserver(resize).observe(this.canvas);
    resize();
  }

  #initMedia() {
    if (!this.mediaElement) return;
    const gl = this.gl;
    this.mediaTex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, this.mediaTex);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  }

  #render(timeMs) {
    const gl = this.gl;
    const t = timeMs * 0.001;
    const res = [this.canvas.width, this.canvas.height];
    const mouse = [this.mouseX, this.mouseY];

    if (this.mediaElement && this.mediaElement.readyState >= 2) {
      gl.bindTexture(gl.TEXTURE_2D, this.mediaTex);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, this.mediaElement);
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, this.sceneFBO.fbo);
    this.sceneProg.use();
    this.sceneProg.set1f('u_time', t);
    this.sceneProg.set2f('u_resolution', ...res);
    this.sceneProg.set2f('u_mouse', ...mouse);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    let inputTex = this.sceneFBO.tex;
    for (let i = 0; i < this.effects.length; i++) {
      const target = i % 2 === 0 ? this.ping : this.pong;
      this.effects[i].fbo = target.fbo;
      this.effects[i].tex = target.tex;
      this.effects[i].draw(inputTex, t, res, mouse, this.mediaTex);
      inputTex = target.tex;
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.viewport(0, 0, res[0], res[1]);
    const final = this.effectProgs.at(-1);
    final.use();
    final.set1f('u_time', t);
    final.set2f('u_resolution', ...res);
    final.set2f('u_mouse', ...mouse);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, inputTex);
    final.set1i('u_scene', 0);

    if (this.mediaTex) {
      gl.activeTexture(gl.TEXTURE1);
      gl.bindTexture(gl.TEXTURE_2D, this.mediaTex);
      final.set1i('u_media', 1);
    }

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(this.#render.bind(this));
  }
}
