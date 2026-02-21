shader_type canvas_item;

// oficiální způsob přístupu k obrazovce
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

// síla rozmazání (v pixelech)
uniform float blur_amount : hint_range(0.0, 20.0) = 6.0;

// 0 = žádné ztmavení, 1 = černo
uniform float darkness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = SCREEN_PIXEL_SIZE * blur_amount;

	vec4 col = vec4(0.0);

	// vážený (pseudo-Gaussian) blur
	col += texture(screen_tex, uv + px * vec2(-1.0, -1.0)) * 0.05;
	col += texture(screen_tex, uv + px * vec2( 0.0, -1.0)) * 0.09;
	col += texture(screen_tex, uv + px * vec2( 1.0, -1.0)) * 0.05;

	col += texture(screen_tex, uv + px * vec2(-1.0,  0.0)) * 0.09;
	col += texture(screen_tex, uv)                          * 0.44;
	col += texture(screen_tex, uv + px * vec2( 1.0,  0.0)) * 0.09;

	col += texture(screen_tex, uv + px * vec2(-1.0,  1.0)) * 0.05;
	col += texture(screen_tex, uv + px * vec2( 0.0,  1.0)) * 0.09;
	col += texture(screen_tex, uv + px * vec2( 1.0,  1.0)) * 0.05;

	// ztmavení
	col.rgb = mix(col.rgb, vec3(0.0), darkness);

	COLOR = col;
}
