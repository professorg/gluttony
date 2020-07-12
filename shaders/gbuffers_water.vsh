#version 130


uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int frameCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#define PI 3.1415926

float noise(float x) {
    return (sin(x) + 0.5*sin(3*x) + 0.3*sin(5*x) + 0.1*sin(7*x))/(1+0.5+0.3+0.1);
}

void main() {
    float variance = 0.08;
    float period = 20.0;
    float speed = 0.03;
    float xmod = 2*PI/period;
    vec3 worldPosition = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz + cameraPosition;
    if (abs(worldPosition.y - round(worldPosition.y)) > 0.01) {
        vec4 shift = variance * vec4(0, noise(xmod*worldPosition.x + speed*frameCounter) + noise(xmod*worldPosition.z + speed*frameCounter), 0, 0);
        gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + shift);
    } else {
        gl_Position = ftransform();
    }
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}
