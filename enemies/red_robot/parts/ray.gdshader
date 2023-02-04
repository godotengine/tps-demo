shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D ray_texture : source_color;
uniform sampler2D smoke_texture : source_color;
uniform float deform = 0.0;
uniform float transparency = 1.0;
uniform float energy = 1.0;
uniform float smoke = 0.0;
uniform float clip = 1000.0;

varying float dist;

void vertex() {
	float deform_amount = 0.01 * deform;
	vec2 offset = vec2(sin(VERTEX.z * 1.4321), sin(VERTEX.z * 2.12351));
	VERTEX.xy += deform_amount * offset;
	VERTEX.xy *= 1.0 + deform;
	dist = abs(VERTEX.z);
}

void fragment() {
	if (dist > clip) {
		discard;
	}
	vec4 ray_color = texture(ray_texture, UV);
	vec4 smoke_color = texture(smoke_texture, UV);

	vec4 col = mix(ray_color, smoke_color, smoke);

	ALBEDO = col.rgb * energy;
	ALPHA = col.a * transparency;
	//ALBEDO=ray_color.rgb;
	//ALPHA=ray_color.a;
}
