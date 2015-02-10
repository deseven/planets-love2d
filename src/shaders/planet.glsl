const number pi = 3.14159265;
const number pi2 = 2.0 * pi;
extern number xrot;
extern number yrot;
extern number resolution = 2;
extern number width = 1;
extern number height = 1;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pixel_coords) {
	vec2 p = 2.0 * (tc - 0.5);							// center on canvas
	number r = sqrt(p.x*width*p.x + p.y*height*p.y);		// sphere size
	if (r > 1.0) discard;
	number d = r != 0.0 ? asin(r) / r : 0.0;
	vec2 p2 = d * p * resolution;
	number x3 = mod(p2.x / pi2 + 0.5 + xrot, 1.0);
	number y3 = mod(p2.y / pi2 + 0.5 + yrot, 1.0);
	vec2 newCoord = vec2(x3, y3);						// location of texture on sphere
	vec4 sphereColor = color * Texel(texture, newCoord);
	return sphereColor;
}