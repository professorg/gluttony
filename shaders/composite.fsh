#version 120

uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D gcolor;
uniform sampler2D depthtex;

varying vec2 texcoord;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
