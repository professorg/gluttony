#version 120

uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;

varying vec2 texcoord;

#define PI 3.1415926
// 1/sqrt(2*PI)
#define GAUSS_FACTOR 0.3989422804

const int MAX_SIZE = 7;
float kernel[MAX_SIZE];

// Relative to camera pos
vec3 fragWorldPos(in vec2 texcoord) {
    float depth_val = texture2D(depthtex0, texcoord).r;
    vec4 norm_screen_pos = vec4(texcoord.s * 2.0 - 1.0, texcoord.t * 2.0 - 1.0, depth_val * 2.0 - 1.0, 1.0);
    vec4 camera_pos = gbufferProjectionInverse * norm_screen_pos;
    camera_pos /= camera_pos.w;
    vec4 world_pos = gbufferModelViewInverse * camera_pos;
    return world_pos.xyz;
}

float gaussian(in float x, in float sigma) {
    return GAUSS_FACTOR / sigma * exp((-x*x)/(2*sigma*sigma));
}

void main() {
//	vec3 color = texture2D(gcolor, texcoord).rgb;
    vec3 color = vec3(0.0);
    float frag_depth = length(fragWorldPos(texcoord));
    float center_depth = length(fragWorldPos(vec2(0.5)));
//    float frag_depth = -log(1 - texture2D(depthtex0, texcoord).r);
//    float center_depth = -log(1 - texture2D(depthtex0, vec2(0.5)).r);
    float delta = sqrt(frag_depth) - sqrt(center_depth);
    float sigma = log(abs(delta) + 1) + 0.001;
    float bound = 4 * sigma;
    int kernel_size = int(ceil(min(2*bound + 1, MAX_SIZE)));    // Clamp to the max array size
    int radius = (kernel_size - 1) / 2; // Update the radius according to the clamped size
    float total = 0.0;
    for (int i = 0; i <= radius; ++i) {
        kernel[radius+i] = kernel[radius-i] = gaussian(i, sigma);
    }
    for (int i = -radius; i <= radius; ++i) {
        for (int j = -radius; j <= radius; ++j) {
            float x_weight = kernel[radius+i];
            float y_weight = kernel[radius+j];
            vec2 tex_offset = vec2(i / viewWidth, j / viewHeight);
            float depth = min(frag_depth, length(fragWorldPos(texcoord + tex_offset)));
            float bias = 1 - exp(-abs(sqrt(depth) - sqrt(center_depth)));
            float weight = x_weight * y_weight * bias;
            total += weight;
            color += weight * texture2D(gcolor, texcoord + tex_offset).rgb;
        }
    }
    color /= total;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
