shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
const vec3 palette[8] = vec3[8](
    vec3(0.051, 0.169, 0.271),  // #0d2b45
    vec3(0.126, 0.235, 0.337),  // #203c56
    vec3(0.329, 0.306, 0.408),  // #544e68
    vec3(0.553, 0.412, 0.478),  // #8d697a
    vec3(0.816, 0.506, 0.349),  // #d08159
    vec3(1.000, 0.667, 0.369),  // #ffaa5e
    vec3(1.000, 0.831, 0.639),  // #ffd4a3
    vec3(1.000, 0.925, 0.839)   // #ffecd6
);

vec3 find_nearest_color(vec3 color) {
    float min_distance = distance(color, palette[0]);
    vec3 nearest_color = palette[0];

    for (int i = 1; i < 8; i++) {
        float dist = distance(color, palette[i]);
        if (dist < min_distance) {
            min_distance = dist;
            nearest_color = palette[i];
        }
    }
    
    return nearest_color;
}

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 nearest_color = find_nearest_color(color.rgb);
    COLOR = vec4(nearest_color, color.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
