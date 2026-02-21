shader_type canvas_item;

uniform float edge_strength : hint_range(0.0, 1.0) = 0.5; // menší = jemnější
uniform float edge_start : hint_range(0.0, 1.0) = 0.5;  // vzdálenost od středu, kde tmavnutí začíná
uniform float edge_end : hint_range(0.0, 1.0) = 0.95;   // vzdálenost od středu, kde tmavnutí dosáhne maxima

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    
    float dist = distance(uv, center);
    
    // menší rozdíl mezi start a end = ostřejší okraj
    // větší rozdíl = jemnější gradient
    float dark = smoothstep(edge_start, edge_end, dist) * edge_strength;
    
    COLOR = vec4(0.0, 0.0, 0.0, dark);
}
