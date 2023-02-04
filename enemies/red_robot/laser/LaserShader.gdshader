shader_type spatial;
render_mode cull_disabled;

uniform sampler2D laser_body_noise;
uniform vec2 uv_scale = vec2(5.0, 1.0);
uniform float offset_uv_x = 0.0;
uniform float cutoff_value : hint_range(0.0, 1.0) = 0.6;
uniform float traversal_scale = 1.0;
uniform float energy = 1.0;

uniform float clip = 4.0;

uniform vec4 color1 : source_color = vec4(0.0, 0.0, 1.0, 1.0);

void vertex(){
	// Because of how the UVs are laid out, the UVs at the right-most place
	// are at the end of the beam. We use that to decide wether or not to
	// apply the clip distance to the laser.
	float should_displace_vertex = step(0.9, UV.x);
	// Here we mix between the vertex original position and the clip position
	// because we use step, only the ring of vertices at the end will have a
	// coefficient of 1.
	float original_z = VERTEX.z;
	VERTEX.z = mix(VERTEX.z, -clip, should_displace_vertex);
	UV.x *= VERTEX.z / original_z;
	VERTEX.xy *= max(0.0, traversal_scale);
}

void fragment() {
	vec2 transformed_uv = UV * uv_scale;
	transformed_uv.x += max(0.0, offset_uv_x);
	float noise_val = texture(laser_body_noise, transformed_uv).r; //noise textures are grayscale
	ALBEDO = color1.rgb;
	if (noise_val < max(0.0, cutoff_value)) {
		discard;
	}
	EMISSION = color1.rgb * energy;
}
