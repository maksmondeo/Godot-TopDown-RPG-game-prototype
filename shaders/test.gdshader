shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

void vertex() {
	VERTEX.y += sin(TIME) * 1.2;
	//VERTEX.x += sin(TIME) * 2.0;
}

void fragment() {
	vec2 noise = 2.0 * texture(noise_texture, UV + vec2(0.5, 0.2) * TIME).rg - vec2(1.0);
	
	COLOR = texture(TEXTURE, UV + noise * 0.0065);
	COLOR *= texture(screen_texture, SCREEN_UV + noise * 0.01);
}