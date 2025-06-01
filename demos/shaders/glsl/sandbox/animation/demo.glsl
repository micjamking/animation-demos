#define PI 3.1415926535

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec3 gradient = 0.5 + 0.5 * sin((u_time) + uv.xyx + vec3(0.0, 2.0, 4.0));
    gl_FragColor = vec4(vec3(gradient), 1.0);
}