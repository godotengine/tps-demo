shader_type spatial;

uniform sampler2D alpha_texture;
uniform float emission_factor = 3.0;

varying float lifetime_percent;
varying float id;

void vertex() {
	id = float(INSTANCE_ID);
	lifetime_percent = INSTANCE_CUSTOM.y;
}

void fragment() {
	float alpha_from_texture = texture(alpha_texture, UV).r;
	float alpha_travel_factor = (UV.y + lifetime_percent + id) * 3.14;
	ALPHA = sin(alpha_travel_factor * 3.0) * sign(sin(alpha_travel_factor * 0.1)) * COLOR.a * alpha_from_texture;
	ALPHA = sin(alpha_travel_factor * 3.0) * sign(sin(alpha_travel_factor * 0.1)) * COLOR.a * alpha_from_texture;
	ALPHA = max(ALPHA, 0.0);
	ALBEDO = COLOR.rgb;
	EMISSION = ALBEDO * emission_factor;
}
