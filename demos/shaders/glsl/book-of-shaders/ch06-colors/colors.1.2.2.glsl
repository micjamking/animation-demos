#version 300 es
#define PI 3.14159265359

precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

vec3 c1 = vec3(0.090, 0.070, 0.220); // deep indigo twilight
vec3 c2 = vec3(0.172, 0.231, 0.447); // pre-dawn blue
vec3 c3 = vec3(0.580, 0.525, 0.686); // early morning lavender
vec3 c4 = vec3(0.988, 0.737, 0.486); // soft apricot
vec3 c5 = vec3(1.000, 0.855, 0.612); // horizon peach glow

vec3 c6  = vec3(1.000, 0.714, 0.286); // brilliant orange highlight
vec3 c7  = vec3(0.925, 0.404, 0.216); // sunset orange-red
vec3 c8  = vec3(0.741, 0.498, 0.192); // burnished gold
vec3 c9  = vec3(0.325, 0.349, 0.561); // smoky blue-purple
vec3 c10 = vec3(0.129, 0.110, 0.227); // deep dusk violet

float plot(vec2 st, float pct) {
    return smoothstep(pct - 0.01, pct, st.y) - smoothstep(pct, pct + 0.01, st.y);
}

vec3 colorAt(float y) {
    if (y < 0.2) {
        return mix(c1, c2, y / 0.2);
    } else if (y < 0.4) {
        return mix(c2, c3, (y - 0.2) / 0.2);
    } else if (y < 0.7) {
        return mix(c3, c4, (y - 0.4) / 0.3);
    } else {
        return mix(c4, c5, (y - 0.7) / 0.3);
    }
}

out vec4 fragColor;
void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    
    vec3 color1 = vec3(0.0);
    vec3 color2 = vec3(0.0);

    float y = smoothstep(0.0, 1.0, st.y);

    if (y < 0.2) {
        color1 = mix(c1, c2, y / 0.2);
    } else if (y < 0.4) {
        color1 = mix(c2, c3, (y - 0.2) / 0.2);
    } else if (y < 0.7) {
        color1 = mix(c3, c4, (y - 0.4) / 0.3);
    } else {
        color1 = mix(c4, c5, (y - 0.7) / 0.3);
    }

    if (y < 0.2) {
        color2 = mix(c6, c7, y / 0.2);
    } else if (y < 0.4) {
        color2 = mix(c7, c8, (y - 0.2) / 0.2);
    } else if (y < 0.7) {
        color2 = mix(c8, c9, (y - 0.4) / 0.3);
    } else {
        color2 = mix(c9, c10, (y - 0.7) / 0.3);
    }

    vec3 color = mix(color1, color2, 0.5 + 0.5 * sin(u_time * 0.25));

    fragColor = vec4(color, 1.0);
}