#version 300 es
precision mediump float;

#define PI 3.14159265359

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

float plot(vec2 st, float pct) {
  return smoothstep( pct - 0.02, pct, st.y) - smoothstep( pct, pct + 0.02, st.y); 
}

out vec4 fragColor;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution;

  float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);

  vec3 color = vec3(y);

  float pct = plot(st, y);
  color = (1.0 - pct) * color + pct * vec3( 0.0, 1.0, 0.0 ); 
  
  fragColor = vec4( color, 1.0 );
}