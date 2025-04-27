/**
 * Types in GLSL
 */
const types = /* glsl */`
  // Primitive (scalar) types
  bool b = true;
  int i = i;
  float f = 3.14159;

  // Type casting
  int i = 2;
  float f = 3.14159;

  float r = float( i ) * f;

  // Type constructors
  int i = 1;
  int i = int( 1 );
  int i = int( 1.9995 );
  int i = int( true );
`;

const vectors = /* glsl */`
  // 2D boolean vector
  bvec2 b2 = bvec2(true, false);

  // 3D integer vector
  ivec3 i3 = ivec3(0, 0, 1);

  // 4D float vector
  vec4 v4 = vec4(0.0, 1.0, 2.0, 3.0);
  float x = v4.x;    // x = 0.0
  float y = v4.y;    // y = 1.0
  float z = v4.z;    // z = 2.0
  float w = v4.w;    // w = 3.0

  float r = v4.r;    // r = 0.0
  float g = v4.g;    // g = 1.0
  float b = v4.b;    // b = 2.0
  float a = v4.a;    // a = 3.0

  float x = v4[0];    // x = 0.0
  float y = v4[1];    // y = 1.0
  float z = v4[2];    // z = 2.0
  float w = v4[3];    // w = 3.0

  // Retrieve only X & Y components
  vex2 xy = v4.xy;    // xy = vec2( 0.0, 1.0 )

  // Retrieve color components in reverse
  vec4 backwards = v4.abgr;
  // backwards = vec4( 3.0, 2.0, 1.0, 0.0);

  // Retrieve arbitrary multiples
  vec3 gag = v4.gag;    // gag = vec4( 1.0, 3.0, 1.0)
`;

const overload = /* glsl */`
  // Overload addition
  vec2 a = vec2( 1.0, 1.0 );
  vec2 b = vec2( 1.0, 1.0 );
  vec2 c = a + b;    // c = vec2( 2.0, 2.0 )

  // Overload constructor
  vec2 a = vec2( 0.0, 0.0 );
  vec2 b = vec2( 1.0, 1.0 );
  vec4 c = vec4( a, b );    // c = vec4( 0.0, 0.0, 1.0, 1.0 )

  vec4 a = vec4( 1.0, 1.0, 1.0, 1.0 );
  vec4 a = vec4( 1.0 );
  vec4 a = vec4( vec2(1.0), vec2(1.0) );
  vec4 a = vec4( v2, float, v4 );
  // vec4( v2.x, v2.y, float, v4.x )
  vec4 a = vec4( v3, float );
  // vec4(v3.x, v3.y, v3.z, float)
`;

const additionalTypes = /* glsl */`
  // Arrays
  int values[3];
  values[0] = 0;
  values[1] = 0;
  values[2] = 0;

  // Struct
  struct ColorStruct {
    vec3 color0;
    vec3 color1;
    vec3 color2;
  }

  // Initialize struct
  ColorStruct sandy = ColorStruct(
    vec3( 0.92, 0.83, 0.60 ),
    vec3( 1.0, 0.94, 0.69 ),
    vec3( 0.95, 0.86, 0.69 ),
  );

  // Access values from struct
  sandy.color0    // vec3( 0.92, 0.83, 0.60 )
`;

const conditions = /* glsl */`
  // Conditions
  if ( condition ) {
  
  } else {
  
  }

  // For loops
  const int count = 10;
  for( int i = 0; i <= count; i++ ){
    // do something
  }

  // For loops (with floats)
  const float count = 10.;
  for( float i = 0.0; i <= count; i+= 1.0 ){
    // do something
  }

  // Break & continue
  // *NOTE: break does not work on all hardware
  const float count = 10.;
  for( float i = 0.0; i <= count; i+= 1.0 ){
    if (i < 5.) continue;
    if (i >= 8. ) break;
  }
`;

const qualifiers = /* glsl */`
  // Attributes (VS only)
  
  // Uniforms (VS+FS)
  uniform vec2 u_resolution; 
  // Passing on canvas coordinations from CPU -> GPU
  // Values cannot be set at runtime (same as const)

  // Function signatures
  void banana( inout float a ){
    a += 1.;
  }

  float A = 0.;
  banana( A );    // now A = 1.0
`;

/**
  Additional notes on GLSL:
    - 'Y' is flipped (points up) in WebGL,
      whereas 'Y' points down in the DOM
    - The window origin is the bottom left corner in WebGL,
      instead of top left like the DOM
  

 */