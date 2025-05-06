precision mediump float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform float u_time;

void main() {

    vec2 uv = gl_FragCoord.xy / u_resolution;

    float myRectX = step(0.25, uv.x) - step(0.75, uv.x);
    gl_FragColor = vec4(vec3(1.0 - myRectX), 1.0);
}