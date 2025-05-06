/* eslint-disable no-unused-vars */
import { ShaderApp } from '../../shared/main.js';

/* =========================================================================
   Shader sources (inline template strings for portability)
   ========================================================================= */

const VERT_SRC = /* glsl */`
  attribute vec2 position;
  void main() {
    gl_Position = vec4(position, 0.0, 1.0);
  }
`;

/**
 * 1.0 - Plot a line
 */
const FRAG_SRC_EX_1 = /* glsl */`
  precision mediump float;

  uniform vec2 u_mouse;
  uniform vec2 u_resolution;
  uniform float u_time;

  // Plot a line on Y using a value between 0.0-1.0
  float plot(vec2 st) {
    return smoothstep( 0.02, 0.0, abs(st.y - st.x)); 
  }
  
  void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    float y = st.x;

    vec3 color = vec3(y);

    float pct = plot(st);
    color = (1.0 - pct) * color + pct * vec3( 0.0, 1.0, 0.0 ); 
    
    gl_FragColor = vec4( color, 1.0 );
  }
`;

/**
 * 2.0 - Shape a line
 */
const FRAG_SRC_EX_2 = /* glsl */`
  precision mediump float;

  uniform vec2 u_mouse;
  uniform vec2 u_resolution;
  uniform float u_time;

  #define PI 3.14159265359

  float plot(vec2 st, float pct) {
    return smoothstep( pct - 0.02, pct, st.y) - smoothstep( pct, pct + 0.02, st.y); 
  }
  
  void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);

    vec3 color = vec3(y);

    float pct = plot(st, y);
    color = (1.0 - pct) * color + pct * vec3( 0.0, 1.0, 0.0 ); 
    
    gl_FragColor = vec4( color, 1.0 );
  }
`;

/* =========================================================================
   Kick things off
   ========================================================================= */
new ShaderApp(document.querySelector('canvas'), {
  vertex: VERT_SRC,
  fragment: FRAG_SRC_EX_2
});
