#version 300 es
#define PI 3.14159265359
precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;
float strokeWidth = 0.005;

float plot(vec2 st, float pct) {
  return smoothstep( pct - strokeWidth, pct, st.y) - smoothstep( pct, pct + strokeWidth, st.y); 
}

out vec4 fragColor;
void main(){
    // Canvas resolution
    vec2 st = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    st *= mix(vec2(1.0, 1.0 / aspect), vec2(aspect, 1.0), step(1.0, aspect));

    // Grid resolution (scaled)
    vec2 uv = st * 2.0;
    uv -= vec2(aspect, 0.0);

    vec3 color = vec3(0.0);
    vec3 black = color;
    vec3 red = vec3(1.0, 0.0, 0.0);

    // Table of equations - https://thebookofshaders.com/05/kynd.png
    // float pct = 1.0 - pow(abs(sin(u_time)), 0.5);
    // float pct = 1.0 - pow(abs(sin(u_time)), 1.0);
    // float pct = 1.0 - pow(abs(sin(u_time)), 1.5);
    // float pct = 1.0 - pow(abs(sin(u_time)), 2.0);
    // float pct = 1.0 - pow(abs(sin(u_time)), 2.5);
    // float pct = 1.0 - pow(abs(sin(u_time)), 3.0);
    // float pct = 1.0 - pow(abs(sin(u_time)), 3.5);
    
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 0.5);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 1.0);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 1.5);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 2.0);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 2.5);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 3.0);
    // float pct = pow(cos(PI * sin(u_time) / 2.0), 3.5);
    
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 0.5);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 1.0);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 1.5);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 2.0);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 2.5);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 3.0);
    // float pct = 1.0 - pow(abs(sin(PI * sin(u_time) / 2.0)), 3.5);
    
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 0.5);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 1.0);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 1.5);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 2.0);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 2.5);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 3.0);
    // float pct = pow(min(cos(PI * sin(u_time) / 2.0), 1.0 - abs(sin(u_time))), 3.5);
    
    float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 0.5);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 1.0);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 1.5);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 2.0);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 2.5);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 3.0);
    // float pct = 1.0 - pow(max(0.0, abs(sin(u_time)) * 2.0 - 1.0), 3.5);

    // float pct = (abs(sin(u_time)));
    
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
    
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 0.5);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 1.0);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 1.5);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 2.0);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 2.5);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 3.0);
    // float y = pow(min(cos(PI * uv.x / 2.0), 1.0 - abs(uv.x)), 3.5);
    
    float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 0.5);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 1.0);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 1.5);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 2.0);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 2.5);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 3.0);
    // float y = 1.0 - pow(max(0.0, abs(uv.x) * 2.0 - 1.0), 3.5);
    
    float plt = plot(uv, y);
    
    color = (1.0 - plt) * color + plt * vec3( 1.0, 0.0, 0.0 );

    color += mix(black, red, pct);

    fragColor = vec4(color, 1.0);
}