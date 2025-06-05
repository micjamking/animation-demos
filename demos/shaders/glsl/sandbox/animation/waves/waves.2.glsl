#version 300 es
#define PI 3.14159265359

precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

float plot(vec2 st, float pct) {
  return smoothstep( pct - 0.005, pct, st.y) - smoothstep( pct, pct + 0.005, st.y); 
}

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}

vec3 addGrain(vec2 uv, float time) {
  float grain = hash(uv * time) * 0.075;
  return vec3(grain);
}

vec3 scanline(vec2 uv) {
    float line = sin(uv.y * 800.0) * 0.02;
    return vec3(line);
}

float vignette(vec2 uv, float aspect) {
  vec2 dist;
  if (aspect >= 1.0){
    dist = uv - vec2((u_resolution.x / u_resolution.y) * 0.5, 0.5);
  } else {
    dist = uv - vec2(0.5, (u_resolution.y / u_resolution.x) * 0.5);
  }
  return smoothstep(0.99, 0.75, dot(dist, dist) * 0.75);
}

out vec4 fragColor;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  // Adjust st to maintain aspect ratio
  st *= mix(vec2(1.0, 1.0 / aspect), vec2(1.0 * aspect, 1.0), step(1.0, aspect));

  vec3 color = vec3(0.0);
  // float rows = 35.0;

  // vec2 uv = gl_FragCoord.xy / u_resolution;
  // float i = floor(uv.y * rows);
  // float localY = fract(uv.y * rows);
  // uv = vec2(st.x, localY);

  // float y = (i * 0.05) + sin((((i / 5.0 * (5.0 * (sin(u_time/1.35) + 1.0))) - i) + (uv.x * PI * 8.0))) / 20.0;
  // float pct = plot(uv, y);
  // vec3 shapeColor = 0.5 + 0.5 * sin((u_time - (i / 10.0)) + uv.xyx + vec3(0.0, 2.0, 4.0)); 
  // color += pct * shapeColor;

  for (int i = 0; i < 35; i++){
    float y = (float(i) * 0.05) + sin((((float(i) / 5.0 * (5.0 * (sin(u_time/1.35) + 1.0))) - float(i)) + (st.x * PI * 8.0))) / 20.0;
    float pct = plot(st, y);
    vec3 shapeColor = 0.5 + 0.5 * sin((u_time - (float(i) / 10.0)) + st.xyx + vec3(0.0, 2.0, 4.0)); 
    color += pct * shapeColor;
  }

  color += addGrain(st, u_time);
  color += scanline(st);
  color *= vignette(st, aspect);

  fragColor = vec4( color, 1.0 );
}