shader_type canvas_item;

uniform float heat_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	vec3 heat_color = mix(vec3(1.0), vec3(1.0, 0.3, 0.0), heat_amount);
	color.rgb *= heat_color;
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
