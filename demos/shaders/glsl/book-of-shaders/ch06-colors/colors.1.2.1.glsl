#version 300 es
#define PI 3.14159265359

precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

vec3 c1 = vec3(0.988, 0.682, 0.259); // peach/orange highlight
vec3 c2 = vec3(0.902, 0.380, 0.224); // saturated orange-red
vec3 c3 = vec3(0.725, 0.616, 0.325); // warm gold
vec3 c4 = vec3(0.294, 0.357, 0.525); // cool blue/purple
vec3 c5 = vec3(0.137, 0.118, 0.255); // deep violet

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
    
    vec3 color = vec3(0.0);

    float y = smoothstep(0.0, 1.0, st.y);
    float horizon = 0.44;

    if (y < 0.2) {
        color = mix(c1, c2, y / 0.2);
    } else if (y < 0.4) {
        color = mix(c2, c3, (y - 0.2) / 0.2);
    } else if (y < 0.7) {
        color = mix(c3, c4, (y - 0.4) / 0.3);
    } else {
        color = mix(c4, c5, (y - 0.7) / 0.3);
    }

    vec3 hueShift = vec3(
        0.02 * sin(st.x * 8.0 + u_time),
        0.01 * cos(st.x * 5.0 + u_time * 0.5),
        0.015 * sin(st.x * 13.0 + u_time * 0.3)
    );

    float sunX = 0.5 + sin(u_time * 0.5) * 0.6;
    float sunPhase = 0.5 + sin(u_time * 1.0);
    float radius = mix(0.1, 0.2, (sunX + 1.0));

    float sun = smoothstep(radius, 0.0, length(st - vec2(sunX, horizon)));
    float clouds = sin(st.x * 6.0 + u_time * 0.25) * 0.1;
    float band = smoothstep(0.46, 0.54, y + clouds);

    vec2 reflectedST = vec2(st.x, horizon - (st.y - horizon));
    vec3 reflectedColor = colorAt(reflectedST.y);
    float reflectionMask = smoothstep(0.0, 0.05, horizon - y);

    color += vec3(1.0, 0.7, 0.3) * (sun * 0.3);
    color = mix(color, vec3(1.0), band * 0.1);
    color += hueShift;
    color = mix(color, reflectedColor, reflectionMask * 0.3);

    fragColor = vec4(color, 1.0);
}