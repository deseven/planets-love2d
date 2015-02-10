// based on https://www.shadertoy.com/view/4dXGR4#

extern float exttime;
extern float rottime;
extern float fcolorType = 0;

// by trisomie21
float snoise(vec3 uv, float res) {
	const vec3 s = vec3(1e0, 1e2, 1e4);

	uv *= res;
	
	vec3 uv0 = floor(mod(uv, res))*s;
	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);
	
	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);
	
	vec4 r = fract(sin(v*1e-3)*1e5);
	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	r = fract(sin((v + uv1.z - uv0.z)*1e-3)*1e5);
	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	return mix(r0, r1, f.z)*2.-1.;
}

vec4 effect( vec4 incolor, Image texture, vec2 texture_coords, vec2 screen_coords ) {

	float brightness	= 0.1;
	float radius		= 0.24 + brightness * 0.2;
	float invRadius 	= 1.0/radius;
	
	vec3 fcolor;
	vec3 fcolorDark;
	if (fcolorType == 0) {
		fcolor = vec3( 1.0, 0.4, 0.1 );
		fcolorDark = vec3( 0.9, 0.4, 0.1 );
	}
	if (fcolorType == 1) {
		fcolor = vec3( 0.6, 0.6, 1.0 );
		fcolorDark = vec3( 0.3, 0.3, 0.8 );
	}
	if (fcolorType == 2) {
		fcolor = vec3( 0.9, 0.65, 0.8 );
		fcolorDark = vec3( 0.7, 0.35, 0.8 );
	}
	if (fcolorType == 3) {
		fcolor = vec3( 0.5, 0.9, 0.5 );
		fcolorDark = vec3( 0.25, 0.8, 0.25 );
	}
	if (fcolorType == 4) {
		fcolor = vec3( 0.9, 0.5, 0.5 );
		fcolorDark = vec3( 0.7, 0.25, 0.25 );
	}

	float time		= exttime * 0.1;
	vec2 uv			= 1.0 * texture_coords;
	vec2 p 			= -0.5 + uv;

	float fade		= pow( length( 2.0 * p ), 0.5 );
	float fVal1		= 1.0 - fade;
	float fVal2		= 1.0 - fade;
	
	float angle		= atan( p.x, p.y )/6.2832;
	float dist		= length(p);
	vec3 coord		= vec3( angle, dist, time * 0.1 );
	
	float newTime1	= abs( snoise( coord + vec3( 0.0, -time * ( 0.35 + brightness * 0.001 ), time * 0.015 ), 15.0 ) );
	float newTime2	= abs( snoise( coord + vec3( 0.0, -time * ( 0.15 + brightness * 0.001 ), time * 0.015 ), 45.0 ) );

	for( int i=1; i<=7; i++ ){
		float power = pow( 2.0, float(i + 1) );
		fVal1 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 10.0 ) * ( newTime1 + 1.0 ) ) );
		fVal2 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 25.0 ) * ( newTime2 + 1.0 ) ) );
	}
	
	float corona		= pow( fVal1 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
	corona				+= pow( fVal2 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
	corona				*= 1.2 - newTime1;
	vec3 sphereNormal 	= vec3( 0.0, 0.0, 1.0 );
	vec3 dir 			= vec3( 0.0 );
	vec3 center			= vec3( 0.5, 0.5, 1.0 );
	vec3 starSphere		= vec3( 0.0 );
	
	vec2 sp = -1.0 + 2.0 * uv;
	sp *= ( 2.0 - brightness );
	float r = dot(sp,sp);
	float f = (1.0-sqrt(abs(1.0-r)))/(r) + brightness * 0.5;
	if( dist < radius ){
		corona			*= pow( dist * invRadius, 12.0 );
		vec2 newUv;
		newUv.x = sp.x*f;
		newUv.y = sp.y*f;
		newUv += vec2( rottime, 0.0 );
		if (newUv.y < 0.) {newUv.y += 1.;}
		if (newUv.x < 0.) {newUv.x += 1.;}
		if (newUv.x > 1.) {newUv.x -= floor(newUv.x);}

		vec3 texSample 	= texture2D( texture, newUv ).rgb;
		float uOff		= ( texSample.r * brightness * 4.5 + rottime );
		vec2 starUV		= newUv + vec2( uOff, 0.0 );
		if (starUV.y < 0.) {starUV.y += 1.;}
		if (starUV.y > 1.) {starUV.y -= floor(starUV.y);}
		if (starUV.x < 0.) {starUV.x += 1.;}
		if (starUV.x > 1.) {starUV.x -= floor(starUV.x);}
		starSphere		= texture2D( texture, starUV ).rgb;
	}
	
	float starGlow	= min( max( 0.6 - dist, 0.0 ), 1.0 );
	vec3 outcolor	= vec3( f * ( 0.75 + brightness * 0.3 ) * fcolor ) + starSphere + corona * fcolor + starGlow * fcolorDark;
	if (outcolor.r > 1.) {outcolor.r = 1.0;}
	if (outcolor.g > 1.) {outcolor.g = 1.0;}
	if (outcolor.b > 1.) {outcolor.b = 1.0;}

	// adding alpha
	float alpha = outcolor.r;
	if (outcolor.g > alpha) {alpha = outcolor.g;}
	if (outcolor.b > alpha) {alpha = outcolor.b;}
	float delta = 1./alpha;
	outcolor.g *= delta;
	outcolor.b *= delta;
	outcolor.r *= delta;

	return vec4(outcolor,alpha);
}
