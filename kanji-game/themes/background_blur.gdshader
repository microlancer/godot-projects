shader_type canvas_item;

uniform float blur_amount = 2.5;
uniform sampler2D texture_: filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = textureLod(texture_,UV,blur_amount);
	COLOR = tex;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
