#version 130

attribute vec3 mc_Entity;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int frameCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#define PI 3.1415926

float noise(float x) {
    return (sin(x) + 0.5*sin(3*x) /*+ 0.3*sin(5*x) + 0.1*sin(7*x)*/)/(1+0.5/*+0.3+0.1*/);
}

float waterNoise(float x) {
    return (sin(x) + 0.5*sin(3*x) + 0.3*sin(5*x) + 0.1*sin(7*x))/(1+0.5+0.3+0.1);
}

void main() {
    float variance = 0.04;
    float period = 40.0;
    float speed = 0.03;
    float xmod = 2*PI/period;
    vec3 worldPosition = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz + cameraPosition;
    if (mc_Entity.x == 1) {
        vec4 shift = variance * vec4(noise(xmod*worldPosition.x + speed*frameCounter), noise(xmod*worldPosition.y + speed*frameCounter), noise(xmod*worldPosition.z + speed*frameCounter), 0);
        gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + shift);
    } else if (mc_Entity.x == 2) {
        variance = 0.08;
        period = 20.0;
        speed = 0.03;
        xmod = 2*PI/period;
        vec4 shift = variance * vec4(
                waterNoise(xmod*worldPosition.x + speed*frameCounter),
                waterNoise(xmod*worldPosition.x + speed*frameCounter) + waterNoise(xmod*worldPosition.z + speed*frameCounter),
                waterNoise(xmod*worldPosition.z + speed*frameCounter), 0);
        gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + shift);
    } else {
        gl_Position = ftransform();
    }
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}
