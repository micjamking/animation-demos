import { ShaderApp } from '../../_shared/shader.js';

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

  uniform vec2 u_mouse;
  uniform vec2 u_resolution;
  uniform float u_time;

  #define PI 3.1415926535
  
  void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec3 col = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0.0, 2.0, 4.0));
    gl_FragColor = vec4( col, 1.0 );
  }
`;

/* =========================================================================
   Kick things off
   ========================================================================= */
new ShaderApp(document.querySelector('canvas'), {
  vertex: VERT_SRC,
  fragment: FRAG_SRC
});
