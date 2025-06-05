#version 300 es
precision mediump float;

#define PI 3.14159265359

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

float amplitude = 0.1;
float wavelength = 10.0;
float position = 0.5;
float strokeWidth = 0.005;

float plot(vec2 st, float pct) {
  return smoothstep( pct - strokeWidth, pct, st.y) - smoothstep( pct, pct + strokeWidth, st.y); 
}

float gridlines(vec2 uv, float size, float brightness){
  uv *= size;
  float yLines = (1.0 - smoothstep(0.0, 0.02, abs(fract(uv.y - 0.5) - 0.5))) * brightness;
  float xLines = (1.0 - smoothstep(0.0, 0.02, abs(fract(uv.x - 0.5) - 0.5))) * brightness;
  return max(yLines, xLines);
}

out vec4 fragColor;

void main() {
  // Canvas resolution
  vec2 st = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  st *= mix(vec2(1.0, 1.0 / aspect), vec2(aspect, 1.0), step(1.0, aspect));
  
  vec3 color = vec3(0.0);

  // Grid resolution (scaled)
  vec2 uv = st * 2.0;
  uv -= vec2(1.0, 0.0);

  // Table of equations - https://thebookofshaders.com/05/kynd.png
  // float y = 1.0 - pow(abs(uv.x), 0.5);
  // float y = 1.0 - pow(abs(uv.x), 1.0);
  // float y = 1.0 - pow(abs(uv.x), 1.5);
  // float y = 1.0 - pow(abs(uv.x), 2.0);
  // float y = 1.0 - pow(abs(uv.x), 2.5);
  // float y = 1.0 - pow(abs(uv.x), 3.0);
  // float y = 1.0 - pow(abs(uv.x), 3.5);

  // float y = pow(cos(PI * uv.x / 2.0), 0.5);
  // float y = pow(cos(PI * uv.x / 2.0), 1.0);
  // float y = pow(cos(PI * uv.x / 2.0), 1.5);
  // float y = pow(cos(PI * uv.x / 2.0), 2.0);
  // float y = pow(cos(PI * uv.x / 2.0), 2.5);
  // float y = pow(cos(PI * uv.x / 2.0), 3.0);
  // float y = pow(cos(PI * uv.x / 2.0), 3.5);
  
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 0.5);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 1.0);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 1.5);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 2.0);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 2.5);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 3.0);
  // float y = 1.0 - pow(abs(sin(PI * uv.x / 2.0)), 3.5);

  float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 0.5);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 1.0);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 1.5);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 2.0);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 2.5);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 3.0);
  // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 3.5);
  
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 0.5);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 1.0);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 1.5);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 2.0);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 2.5);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 3.0);
  // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 3.5);

  float pct = plot(uv, y);
  float grid = gridlines(st, 20.0, 0.1);
  
  color = (1.0 - pct) * color + pct * vec3( 0.0, 1.0, 0.0 );
  color += grid;
  
  fragColor = vec4( color, 1.0 );
}