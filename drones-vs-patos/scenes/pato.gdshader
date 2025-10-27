shader_type spatial;

uniform sampler2D tex;
uniform sampler2D noise_img1: repeat_enable;

uniform vec4 tint_color1 : source_color = vec4(1.0f,1.0f,1.0f,1.0f);
uniform sampler2D noise_img2: repeat_enable;
uniform vec4 tint_color2 : source_color = vec4(1.0f,1.0f,1.0f,1.0f);
uniform sampler2D noise_img3: repeat_enable;
uniform vec4 tint_color3 : source_color = vec4(1.0f,1.0f,1.0f,1.0f);
void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(tex, UV);
    ALBEDO = vec3(color.r, color.g, color.b);
	ALBEDO *= COLOR.rgb;
	ALPHA = color.a;
}