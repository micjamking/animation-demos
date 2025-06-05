#version 300 es
precision mediump float;

#define PI 3.14159265359

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

// Plot a line on Y using a value between 0.0-1.0
float plot(vec2 st, float pct) {
  return smoothstep( pct - 0.02, pct, st.y) - smoothstep( pct, pct + 0.02, st.y); 
}

out vec4 fragColor;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution;

  float y = pow(st.x, 5.0);

  vec3 color = vec3(y);

  float pct = plot(st, y);
  color = (1.0 - pct) * color + pct * vec3( 0.0, 1.0, 0.0 ); 
  
  fragColor = vec4( color, 1.0 );
}