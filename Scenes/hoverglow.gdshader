shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.35, 1.0);
uniform float glow_strength : hint_range(0.0, 3.0) = 0.0;
uniform float glow_size : hint_range(0.0, 10.0) = 3.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float glow = 0.0;

	for (float x = -1.0; x <= 1.0; x += 1.0) {
		for (float y = -1.0; y <= 1.0; y += 1.0) {
			vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE * glow_size;
			glow = max(glow, texture(TEXTURE, UV + offset).a);
		}
	}

	COLOR = tex;

	if (glow_strength > 0.0 && tex.a < glow) {
		COLOR.rgb = glow_color.rgb;
		COLOR.a = glow * glow_strength;
	}
}