precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 size = vec2(0.75, 0.15);
  vec2 pos = vec2(0.5, 0.5);
  
  float marginX = step(pos.x - (size.x / 2.0), uv.x) - step(pos.x + (size.x / 2.0), uv.x);
  float marginY = step(pos.y - (size.y / 2.0), uv.y) - step(pos.y + (size.y / 2.0), uv.y);
  float margin = marginX * marginY;
  vec4 color = vec4(margin, 0.5, 0.5, 1.0);
  gl_FragColor = color;
}