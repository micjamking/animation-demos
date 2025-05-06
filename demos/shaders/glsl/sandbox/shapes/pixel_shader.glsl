precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec4 color = vec4(1.0, 0.2, 0.8, 1.0);
  gl_FragColor = color;
}