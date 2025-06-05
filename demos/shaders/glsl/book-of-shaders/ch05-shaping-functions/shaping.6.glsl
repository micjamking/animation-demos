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
  vec2 st = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  st *= mix(vec2(1.0, 1.0 / aspect), vec2(aspect, 1.0), step(1.0, aspect));

  // Multiplying st.x by PI doubles the phases
  float y1 = position + sin((u_time * 2.5) + (st.x * PI) * wavelength) * amplitude;
  float y2 = position + sin(((u_time * 2.5) - 0.25) + (st.x * PI) * wavelength) * amplitude;
  float y3 = position + sin(((u_time * 2.5) - 0.5) + (st.x * PI) * wavelength) * amplitude;
  // float y = position + abs(sin(u_time + (st.x * PI) * wavelength)) * amplitude;
  // float y = position + fract(sin(u_time + (st.x * PI) * wavelength)) * amplitude;
  // float y = position + (ceil(sin(u_time + (st.x * PI) * wavelength)) + floor(sin(u_time + (st.x * PI) * wavelength))) * amplitude;
  // float y = position + mod((u_time + (st.x * PI) * wavelength), 0.5) * amplitude;
  // float y = position + fract((u_time + (st.x * PI) * wavelength)) * amplitude;
  
  float grid = gridlines(st, 20.0, 0.1);
  
  vec3 color = vec3(0.0);
  vec3 color2 = vec3(0.0);
  vec3 color3 = vec3(0.0);

  float pct = plot(st, y1);
  float pct2 = plot(st, y2);
  float pct3 = plot(st, y3);
  
  color = (1.0 - pct) * color + pct * vec3( 1.0, 0.0, 0.0 );
  color2 = (1.0 - pct2) * color + pct2 * vec3( 0.0, 1.0, 0.0 );
  color3 = (1.0 - pct3) * color + pct3 * vec3( 0.0, 0.0, 1.0 );
  
  color += color2;
  color += color3;
  color += grid;
  
  fragColor = vec4( color, 1.0 );
}