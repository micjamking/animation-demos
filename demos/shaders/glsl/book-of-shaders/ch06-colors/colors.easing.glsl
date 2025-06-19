#version 300 es
#define PI 3.14159265359
precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;
float strokeWidth = 0.005;

float plot(vec2 st, float pct) {
  return smoothstep( pct - strokeWidth, pct, st.y) - smoothstep( pct, pct + strokeWidth, st.y); 
}

// Robert Penner's easing functions in GLSL
// https://github.com/stackgl/glsl-easings
float linear(float t) {
    return t;
}

float exponentialIn(float t) {
    return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

float exponentialOut(float t) {
    return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

float exponentialInOut(float t) {
 return t == 0.0 || t == 1.0
     ? t
     : t < 0.5
         ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
         : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}

float sineIn(float t) {
    return sin((t - 1.0) * (PI / 2.0)) + 1.0;
}

float sineOut(float t) {
    return sin(t * (PI / 2.0));
}

float sineInOut(float t) {
    return -0.5 * (cos(PI * t) - 1.0);
}

float qinticIn(float t) {
    return pow(t, 5.0);
}

float qinticOut(float t) {
    return 1.0 - (pow(t - 1.0, 5.0));
}

float qinticInOut(float t) {
    return t < 0.5 ? +16.0 * pow(t, 5.0) : -0.5 * pow(2.0 * t - 2.0, 5.0) + 1.0;
}

float quarticIn(float t) {
    return pow(t, 4.0);
}

float quarticOut(float t) {
    return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
}

float quarticInOut(float t) {
    return t < 0.5 ? +8.0 * pow(t, 4.0) : -8.0 * pow(t - 1.0, 4.0) + 1.0;
}

float quadraticIn(float t) {
    return t * t;
}

float quadraticOut(float t) {
    return -t * (t - 2.0);
}

float quadraticInOut(float t) {
    float p = 2.0 * t * t;
    return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float cubicIn(float t) {
    return t * t * t; 
}

float cubicOut(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}

float cubicInOut(float t) {
    return t < 0.5 ? 4.0 * t * t * t : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

float elasticIn(float t) {
    return sin(13.0 * t * (PI / 2.0)) * pow(2.0, 10.0 * (t - 1.0));
}

float elasticOut(float t) {
    return sin(-13.0 * (t + 1.0) * (PI / 2.0)) * pow(2.0, -10.0 * t) + 1.0;
}

float elasticInOut(float t) {
    return t < 0.5 
        ? 0.5 * sin(+13.0 * (PI / 2.0) * 2.0 * t) * pow(2.0, 10.0 * (2.0 * t - 1.0))
        : 0.5 * sin(-13.0 * (PI / 2.0) * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 1.0;
}

float circularIn(float t) {
    return 1.0 - sqrt(1.0 - t * t);
}

float circularOut(float t) {
    return sqrt((2.0 - t) * t);
}

float circularInOut(float t) {
    return t < 0.5
        ? 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t))
        : 0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0);
}

float bounceOut(float t) {
    const float a = 4.0 / 11.0;
    const float b = 8.0 / 11.0;
    const float c = 9.0 / 10.0;

    const float ca = 4356.0 / 361.0;
    const float cb = 35442.0 / 1805.0;
    const float cc = 16061.0 / 1805.0;

    float t2 = t * t;

    return t < a
        ? 7.5625 * t2
        : t < b
            ? 9.075 * t2 - 9.9 * t + 3.4
            : t < c
                ? ca * t2 - cb * t + cc
                : 10.8 * t * t - 20.52 * t + 10.72;
}

float bounceIn(float t) {
    return 1.0 - bounceOut(1.0 - t);
}

float bounceInOut(float t) {
    return t < 0.5 
        ? 0.5 * (1.0 - bounceOut(1.0 - t * 2.0))
        : 0.5 * bounceOut(t * 2.0 - 1.0) + 0.5;
}

float backIn(float t) {
    return pow(t, 3.0) - t * sin(t * PI);
}

float backOut(float t) {
    float f = 1.0 - t;
    return 1.0 - (pow(f, 3.0) - f * sin(f * PI));
}

float backInOut(float t) {
    float f = t < 0.5
        ? 2.0 * t
        : 1.0 - (2.0 * t - 1.0);

    float g = pow(f, 3.0) - f * sin(f * PI);

    return t < 0.5
        ? 0.5 * g
        : 0.5 * (1.0 - g) + 0.5;
}

out vec4 fragColor;
void main(){
    // Canvas resolution
    vec2 st = gl_FragCoord.xy / u_resolution;
    float aspect = u_resolution.x / u_resolution.y;
    st *= mix(vec2(1.0, 1.0 / aspect), vec2(aspect, 1.0), step(1.0, aspect));

    // Grid resolution (scaled)
    vec2 uv = st * 2.0;
    uv -= mix(vec2(0.0, 1.0 / aspect), vec2(aspect, 0.0), step(1.0, aspect));

    vec3 color = vec3(0.0);
    vec3 black = color;
    vec3 red = vec3(1.0, 0.0, 0.0);

    float _time = abs(fract(u_time) * 2.0 - 1.0);
    float _x = 1.0 - abs(uv.x);

    // Linear
    // float pct = linear(_time);
    // float y = linear(_x);

    // Exponential In
    // float pct = exponentialIn(_time);
    // float y = exponentialIn(_x);

    // Exponential Out
    // float pct = exponentialOut(_time);
    // float y = exponentialOut(_x);

    // Exponential In Out
    // float pct = exponentialInOut(_time);
    // float y = exponentialInOut(_x);

    // Sine In
    // float pct = sineIn(_time);
    // float y = sineIn(_x);

    // Sine Out
    // float pct = sineOut(_time);
    // float y = sineOut(_x);

    // Sine In Out
    // float pct = sineInOut(_time);
    // float y = sineInOut(_x);

    // Qintic In
    // float pct = qinticIn(_time);
    // float y = qinticIn(_x);

    // Qintic Out
    // float pct = qinticOut(_time);
    // float y = qinticOut(_x);

    // Qintic In Out
    // float pct = qinticInOut(_time);
    // float y = qinticInOut(_x);

    // Quartic In
    // float pct = quarticIn(_time);
    // float y = quarticIn(_x);

    // Quartic Out
    // float pct = quarticOut(_time);
    // float y = quarticOut(_x);

    // Quartic In Out
    // float pct = quarticInOut(_time);
    // float y = quarticInOut(_x);

    // Quadratic In
    // float pct = quadraticIn(_time);
    // float y = quadraticIn(_x);

    // Quadratic Out
    // float pct = quadraticOut(_time);
    // float y = quadraticOut(_x);

    // Quadratic In Out
    // float pct = quadraticInOut(_time);
    // float y = quadraticInOut(_x);

    // Cubic In
    // float pct = cubicIn(_time);
    // float y = cubicIn(_x);

    // Cubic Out
    // float pct = cubicOut(_time);
    // float y = cubicOut(_x);

    // Cubic In Out
    // float pct = cubicInOut(_time);
    // float y = cubicInOut(_x);

    // Elastic In
    // float pct = elasticIn(_time);
    // float y = elasticIn(_x);

    // Elastic Out
    // float pct = elasticOut(_time);
    // float y = elasticOut(_x);

    // Elastic In Out
    // float pct = elasticInOut(_time);
    // float y = elasticInOut(_x);

    // Circular In
    // float pct = circularIn(_time);
    // float y = circularIn(_x);

    // Circular Out
    // float pct = circularOut(_time);
    // float y = circularOut(_x);

    // Circular In Out
    // float pct = circularInOut(_time);
    // float y = circularInOut(_x);

    // Bounce In
    float pct = bounceIn(_time);
    float y = bounceIn(_x);

    // Bounce Out
    // float pct = bounceOut(_time);
    // float y = bounceOut(_x);

    // Bounce In Out
    // float pct = bounceInOut(_time);
    // float y = bounceInOut(_x);

    // Back In
    // float pct = backIn(_time);
    // float y = backIn(_x);

    // Back Out
    // float pct = backOut(_time);
    // float y = backOut(_x);

    // Back In Out
    // float pct = backInOut(_time);
    // float y = backInOut(_x);

    float plt = plot(uv, y);
    color = (1.0 - plt) * color + plt * vec3( 1.0, 0.0, 0.0 );
    color += mix(black, red, pct);

    fragColor = vec4(color, 1.0);
}