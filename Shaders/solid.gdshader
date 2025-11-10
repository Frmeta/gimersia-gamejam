shader_type canvas_item;

uniform int is_tinted : hint_range(0, 1, 1) = 0;
uniform vec4 custom_tint: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
    float alpha = original_color.a;
	
    vec4 tinted_color = vec4(1.0, 1.0, 1.0, alpha);
	COLOR = mix(original_color, tinted_color, float(is_tinted));
}
