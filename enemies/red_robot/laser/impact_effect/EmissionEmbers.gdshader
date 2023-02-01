shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx, cull_disabled;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float emission_energy;


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	EMISSION = (ALBEDO.rgb)*emission_energy;
//	ALPHA = albedo.a * albedo_tex.a;
}
