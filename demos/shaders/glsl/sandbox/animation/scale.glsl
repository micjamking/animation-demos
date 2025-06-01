#define PI 3.1415926535

precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

float radius = 0.025;
float scaleDelay = 0.01875;
float colorDelay = 0.005;

float myCircle(float size, vec2 uv, vec2 pos){
 return 1.0 - smoothstep(size, size + 0.005, length(uv - pos));
}

float limitedSin(float minVal, float maxVal, float x){
 return minVal + (maxVal - minVal) * (sin(x) + 1.0) / 2.0;
}

void main(){
 vec2 uv = gl_FragCoord.xy / u_resolution;
 float aspect = u_resolution.x / u_resolution.y;
 float centerX = 0.0;
 float centerY = 0.0;
 if (aspect >= 1.0) {
  uv.x *= aspect;
 } else {
  uv.y /= aspect;
 }

 vec2 myUV = uv.xy;
 vec3 color = vec3(0.0);
 int row = 0;
 int col = 0;
 float itemsInRow = 0.0;
 float itemsInCol = 0.0;

 if (aspect >= 1.0) {
  itemsInRow = floor(aspect / ((radius * 2.0) + radius));
  itemsInCol = floor(1.0 / ((radius * 2.0) + radius));
  centerX = aspect / 2.0;
  centerY = 0.5;
 } else {
  itemsInRow = floor(1.0 / ((radius * 2.0) + radius));
  itemsInCol = floor((u_resolution.y / u_resolution.x) / ((radius * 2.0) + radius));
  centerX = 0.5;
  centerY = (u_resolution.y / u_resolution.x) / 2.0;
 } 

//  for (int i = 0; i < 400; i++){
//   float delay = sin(float(i) * colorDelay) + 0.5;
//   int modulus = int(mod(float(i), float(itemsInRow)));
//   if ((modulus == 0) && (i != 0)) {
//    row++;
//    col = 0;
//   }

//   if ((row + 1) > int(itemsInCol)) {
//    break;
//   }
 
//   float posX = float(col) * ((radius * 2.0) + radius);
//   float posY = float(row) * ((radius * 2.0) + radius);
//   float sinRadius = limitedSin(radius - (scaleDelay), radius, float(i) + (-1.0 * u_time) * 2.5);
  
//   float circle = myCircle(
//    sinRadius,
//    myUV.xy,
//    vec2(posX, posY) + (radius * 2.0)
//   );
//   vec3 gradient = 0.5 + 0.5 * sin((u_time - delay) * 2.0 + myUV.xyx + vec3(0.0, 2.0, 4.0));
//   color += circle * gradient;
//   col++;
//  }

 float circle = myCircle(
  0.2,
  myUV.xy,
  vec2(centerX, centerY)
 );
 vec3 gradient = 0.5 + 0.5 * sin((u_time) * 2.0 + myUV.xyx + vec3(0.0, 2.0, 4.0));
 color += circle * gradient;
 gl_FragColor = vec4(color, 1.0);
}