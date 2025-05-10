precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.1415926535

float borderSize = 0.001;
float numberOfSides = 5.0;
float delay = 0.05;
float gap = 0.0125;

float round(float n){
  return floor(0.5 + n);
}

mat2 myRotation(float theta){
  return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

float myPolygonShape(vec2 uv, float nSides, float size, vec2 pos, bool rotate, float rotationDelay){
  if (rotate == true) {
    uv = ((uv.xy - pos) * myRotation(sin(u_time - rotationDelay) * PI)) + pos;
  }
  uv = uv - pos;
  float angles = (2.0 * PI) / nSides;
  float theta = atan(uv.y, uv.x);
  float dist = cos(round(theta / angles) * angles - theta) * length(uv.xy);
  return 1.0 - smoothstep(size, size + 0.005, dist);
}

float myPolygon(vec2 uv, float nSides, float size, float aspect, vec2 pos, bool rotate, float rotationDelay){
  return (myPolygonShape(uv, nSides, size, pos, rotate, rotationDelay) * (1.0 - myPolygonShape(uv, nSides, (size - borderSize), pos, rotate, rotationDelay)));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  float center = aspect / 2.0;
  vec3 col = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0.0, 2.0, 4.0));
  float polygon = 0.0;
  for (int i = 0; i < 100; i++) {
    float size = float(i) * (gap);
    float rotationDelay = float(i) * delay;
    polygon += myPolygon(uv, numberOfSides, size, aspect, vec2(center, 0.5), true, rotationDelay);
  }
  col = col * vec3(polygon);
  gl_FragColor = vec4( col, 1.0 );
}