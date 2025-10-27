shader_type spatial;

uniform vec4 modulate : source_color = vec4(1.0f,1.0f,1.0f,1.0f);

void fragment() {
	ALBEDO *= modulate.rgb;
}
