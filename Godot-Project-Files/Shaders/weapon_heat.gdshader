shader_type canvas_item;

uniform float heat_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 hot_glow_color : source_color = vec4(1.0, 0.4, 0.08, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Heat color tint (not too strong)
    color.rgb *= mix(vec3(1.0), vec3(1.0, 0.45, 0.18), heat_amount * 0.6);
    
    // Emission for glow - this survives darkness better
    vec3 emission = hot_glow_color.rgb * pow(heat_amount, 0.6) * glow_intensity;
    
    color.rgb += emission;
    
    COLOR = color;
}