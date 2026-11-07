shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void light() {
    //DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}

void fragment() {
	SPECULAR = 0.0;
	METALLIC = 0.0;
	// Called for every pixel the material is visible on.
	int limit = 309;
	int x = int(floor(FRAGCOORD.r/(FRAGCOORD.b*1.0)*VIEWPORT_SIZE.r));
	int y = int(floor(FRAGCOORD.g/(FRAGCOORD.b*500.0)*VIEWPORT_SIZE.g));
	bool xl = (x%limit==0);
	bool yl = (y%limit==0);
	if ((xl && !yl) || (!xl && yl)) {
		ALPHA = 1.0;
		EMISSION = vec3(0,10,20);
	} else {
		ALPHA = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
