precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

float createQuad(vec2 uv, vec2 size, vec2 pos) {
  float marginX = step(pos.x - (size.x / 2.0), uv.x) - step(pos.x + (size.x / 2.0), uv.x);
  float marginY = step(pos.y - (size.y / 2.0), uv.y) - step(pos.y + (size.y / 2.0), uv.y);
  return marginX * marginY;
}

void main() {
  float square = createQuad(
    gl_FragCoord.xy / u_resolution,
    vec2(0.25, 0.25),
    vec2(0.5, 0.5)
  );
  vec4 color = vec4(vec3(-square + 1.0), 1.0);
  gl_FragColor = color;
}