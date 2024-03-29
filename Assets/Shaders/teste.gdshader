/*
	Pixelart Upscaler/Filter Shader by Firerabbit
	
	MIT License
*/
shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_disabled;

uniform sampler2D albedo_tex: source_color;
uniform vec2 pixel_count = vec2(64);
uniform float FILTER_GAMMA = 1.0;
uniform float COLOR_GAMMA = 1.0;

uniform float mix_amount = 0.0;
uniform vec3 modulate: source_color; 


vec2 snap_UV1(vec2 uv, vec2 steps) {
	return (floor(uv / steps) + 0.5) * steps;
}

void vertex()
{
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
}

float length_squared(vec4 v0) {
	return v0.x*v0.x + v0.y*v0.y + v0.z*v0.z + v0.w*v0.w ;
}
void fragment() {
	vec2 TEXTURE_PIXEL_SIZE = 1.0 / pixel_count;
	vec2 shift = vec2(-TEXTURE_PIXEL_SIZE *.5);
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	
	// sample the color from the filtered image
	vec4 color_sample0 = texture(albedo_tex, UV + pixel_size * .5 + shift);
	
	
	// sample the color from 4 points at positions with a small influence of interpolation
	vec2 sample_uv = snap_UV1(UV + shift, pixel_size);
	vec2 offset = pixel_size; 
	vec4 color_sample1 = texture(albedo_tex, sample_uv + vec2(0.0,0.0));
	vec4 color_sample2 = texture(albedo_tex, sample_uv + vec2(+offset.x,0.0));
	vec4 color_sample3 = texture(albedo_tex, sample_uv + vec2(0.0,+offset.y));
	vec4 color_sample4 = texture(albedo_tex, sample_uv + vec2(+offset.x,+offset.y));
	
	vec4 color = color_sample0;
	
	// gamma adjusment for filtering, affects the brightness influence
	color_sample0 = pow(color_sample0, vec4(FILTER_GAMMA));
	color_sample1 = pow(color_sample1, vec4(FILTER_GAMMA));
	color_sample2 = pow(color_sample2, vec4(FILTER_GAMMA));
	color_sample3 = pow(color_sample3, vec4(FILTER_GAMMA));
	color_sample4 = pow(color_sample4, vec4(FILTER_GAMMA));
	
	// calculating the diviation 
	float d1 = length_squared(color_sample0 - color_sample1);
	float d2 = length_squared(color_sample0 - color_sample2);
	float d3 = length_squared(color_sample0 - color_sample3);
	float d4 = length_squared(color_sample0 - color_sample4);
	
	float d0 = 1000.0;
	
	color = color_sample0;
	
	if (d0 > d1) {
		d0 = d1;
		color = color_sample1;
	}
	
	if (d0 > d2) {
		d0 = d2;
		color = color_sample2;
	}
	if (d0 > d3) {
		d0 = d3;
		color = color_sample3;
	}
	
	if (d0 > d4) {
		d0 = d4;
		color = color_sample4;
	}
	
	color = pow(color, vec4(COLOR_GAMMA/FILTER_GAMMA));
	ALBEDO = mix(color.rgb,modulate.rgb,mix_amount);
	ALPHA = color.a;
}