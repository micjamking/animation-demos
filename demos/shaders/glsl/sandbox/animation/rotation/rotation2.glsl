#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.1415925635

mat2 myRotation(float theta) {
    return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

float myPolygonShape(float nSides, vec2 uv, float size, vec2 pos, bool rotate, float rotationDelay){
    if (rotate) {
        uv = ((uv.xy - pos) * myRotation(sin(u_time - rotationDelay) * PI)) + pos;
    } 
    uv = uv - pos;
    float angles = (2.0 * PI) / nSides;
    float theta = atan(uv.y, uv.x);
    float dist = cos(floor(0.5 + (theta / angles)) * angles - theta) * length(uv.xy);
    return 1.0 - smoothstep(size, size + 0.005, dist);
}

float myPolygon(float nSides, vec2 uv, float size, vec2 pos, float borderSize, bool rotate, float rotationDelay){
    return myPolygonShape(nSides, uv, size, pos, rotate, rotationDelay) * (1.0 - myPolygonShape(nSides, uv, size - borderSize, pos, rotate, rotationDelay));
}

out vec4 fragColor;
void main(){
    vec2 uv = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    float centerX = aspect / 2.0;
    uv.x *= aspect;
    
    vec3 color = vec3(1.0);
    color = 0.5 + 0.5 * sin(u_time + uv.xyx + vec3(0.0, 2.0, 4.0));
    float polygon = 0.0;

    for (int i = 0; i < 100; i++){
        float size = float(i) * 0.0125;
        float delay = float(i) * 0.05;
        polygon += myPolygon(5.0, uv, size * aspect, vec2(centerX, 0.5), 0.001, true, delay);
    }
    
    color *= vec3(polygon);
    fragColor = vec4(color, 1.0);
}