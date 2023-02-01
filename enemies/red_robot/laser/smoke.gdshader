shader_type spatial;
render_mode cull_disabled;

uniform sampler2D smoke_texture;
uniform sampler2D noise_texture;
varying float lifetime_percent;

void vertex(){
	lifetime_percent = INSTANCE_CUSTOM.y;
}

void fragment(){
	float alpha = texture(smoke_texture, UV).r;
	float noise = texture(noise_texture, UV + vec2(0.0, lifetime_percent)).r;
	ALPHA = smoothstep(0.0, 1.0 - lifetime_percent, clamp(alpha * noise - pow(lifetime_percent, 2.0), 0.0,1.0) * COLOR.a);
	ALBEDO = COLOR.rgb;
}
