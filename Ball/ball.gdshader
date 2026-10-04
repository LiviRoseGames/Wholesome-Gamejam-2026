shader_type canvas_item;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Position of the highlight on the ball.
    vec2 highlight_pos = vec2(0.35, 0.30);

    // Distance from the highlight center.
    float distance = length(UV - highlight_pos);

    // Soft circular highlight.
    float highlight = 1.0 - smoothstep(0.0, 0.18, distance);

    // Fade it based on the original sprite's alpha.
    highlight *= tex.a;

    COLOR = vec4(1.0, 1.0, 1.0, highlight * 0.65);
}