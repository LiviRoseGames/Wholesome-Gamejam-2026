shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float edge_size : hint_range(0.0, 0.5) = 0.18;

void fragment() {
	//Curtain color: #9B183C
	vec3 curtain_color = vec3(0.608, 0.094, 0.235);

	//Soft top-to-bottom wipe.
	float edge = smoothstep(
		progress - edge_size,
		progress,
		UV.y
	);

	float alpha = 1.0 - edge;

	//Vertical curtain folds
	float folds = sin(UV.x * 64.0);
	folds = smoothstep(-0.8, 0.8, folds);

	//Subtle shading between the folds
	float shading = mix(0.72, 1.12, folds);

	//Add a second softer layer
	float soft_folds = sin(UV.x * 32.0 + 0.5) * 0.08;
	shading += soft_folds;

	//Slight darkening toward the bottom for depth
	float vertical_shading = mix(1.0, 0.88, UV.y);
	shading *= vertical_shading;

	vec3 final_color = curtain_color * shading;

	COLOR = vec4(final_color, alpha);
}