#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

vec3 colorA = vec3(0.149, 0.141, 0.912);
vec3 colorB = vec3(1.000, 0.833, 0.244);

out vec4 fragColor;
void main(){
    vec3 color = vec3(1.0);

    float pct = abs(sin(u_time));

    color = mix(colorA, colorB, pct);
    
    fragColor = vec4(color, 1.0);
}