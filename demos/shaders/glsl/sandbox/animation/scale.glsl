precision mediump float;

#define PI 3.1415926535897932384626433832795

uniform vec2 u_resolution;
uniform float u_time;

float radius = 0.025;
float borderSize = 0.0;
float borderSmooth = 0.005;
float colorDelay = 0.00125;
float scaleDelay = 0.01875;

float myCircleShape(float size, vec2 uv, vec2 pos){
	return 1.0 - smoothstep(size, size + borderSmooth, length(uv - pos));
}

float myCircle(float size, vec2 uv, vec2 pos){
	if (borderSize == 0.0 || borderSize >= size){
		return myCircleShape(size, uv, pos);
	}
	return myCircleShape(size, uv, pos) * (1.0 - myCircleShape(size - borderSize, uv, pos));
}

mat2 myScale(vec2 scale){
	return mat2(1.0 / scale.x, 0.0, 0.0, 1.0 / scale.y);
}

mat2 myRotate(float theta){
	return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

float limitedSin(float minVal, float maxVal, float x){
	return minVal + (maxVal - minVal) * (sin(x) + 1.0) / 2.0;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / u_resolution;
	float aspect = u_resolution.x / u_resolution.y;
	uv.x *= aspect;
	vec2 myUV = uv.xy;
	// Circles
	vec3 color = vec3(0.0);
	int row = 0;
	int col = 0;

	for (int i = 0; i < 2000; i++){
		float delay = sin(float(i) * colorDelay) + 0.5;
		float itemsInRow = floor(aspect / ((radius * 2.0) + radius));
		float itemsInCol = floor(1.0 / ((radius * 2.0) + radius));
		int modulus = int(mod(float(i), float(itemsInRow)));
		if ((modulus == 0) && (i != 0)) {
			row++;
			col = 0;
		}
		float posX = float(col) * ((radius * 2.0) + radius);
		float posY = float(row) * ((radius * 2.0) + radius);
		if ((row + 1) > int(itemsInCol)) {
			break;
		}
		float sinRadius = limitedSin(radius - (scaleDelay), radius, float(i) * 1.0 + u_time * 2.5);
		float circle = myCircle(sinRadius, myUV.xy, vec2(posX, posY) + (radius * 2.0));
		vec3 circleColor = 0.5 + 0.5 * sin((u_time - delay) * 2.0 + myUV.xyx + vec3(0.0, 2.0, 4.0));
		color += circle * circleColor;
		col++;
	}

	gl_FragColor = vec4(color, 1.0);
}
