shader_type sky;
uniform sampler2D sky_thingy: filter_linear;
uniform sampler2D stars: filter_nearest;
uniform sampler2D map: filter_nearest;
uniform sampler2D temp_gradient: filter_linear;

const float star_radius = 0.99999999;
const float division_thingy = 2800000000.0;
const float powe = 4.0;

vec3 angle_to_unit_dir(float x_rad,float y_rad) {
	float h = radians(-90.0);
	x_rad = -x_rad;
    vec3 unit_dir1 = vec3(cos(x_rad),sin(x_rad),0.0);
    float old_x1 = float(unit_dir1.r);
    unit_dir1.r = old_x1*cos(y_rad+h);
    unit_dir1.b = old_x1*sin(y_rad+h);
    return unit_dir1;
}

vec3 shit(vec3 color_a,vec3 color_b,vec3 color_c,vec3 color_d) {
	return vec3(
		float(
			(uint(floor(color_a.r*255.0)) << uint(0)) + 
			(uint(floor(color_a.g*255.0)) << uint(8)) + 
			(uint(floor(color_a.b*255.0)) << uint(16)) + 
			(uint(floor(color_b.r*255.0)) << uint(24))),
		float(
			(uint(floor(color_b.g*255.0)) << uint(0)) + 
			(uint(floor(color_b.b*255.0)) << uint(8)) + 
			(uint(floor(color_c.r*255.0)) << uint(16)) + 
			(uint(floor(color_c.g*255.0)) << uint(24))),
		float(
			(uint(color_c.b*255.0) << uint(0)) + 
			(uint(color_d.r*255.0) << uint(8)) + 
			(uint(color_d.g*255.0) << uint(16)) + 
			(uint(color_d.b*255.0) << uint(24))));
}
vec2 fuck(vec3 color_a,vec3 color_b) {
	return vec2(
		float(
			(uint(floor(color_a.r*255.0)) << uint(0)) + 
			(uint(floor(color_a.g*255.0)) << uint(8))
		),float(
			(uint(floor(color_a.b*255.0)) << uint(0)) + 
			(uint(floor(color_b.r*255.0)) << uint(8))
		));
}

void sky() {
	if (AT_CUBEMAP_PASS) {
	} else {
		bool in_star = false;
		float star_temp = 0.0;
		float min_distance = 0.0;
		uint neighbor = uint(0);
		{
			
		vec4 index_pointer = texture(map,SKY_COORDS);
		uint star_index = uint(floor(index_pointer.r*255.0)) + (uint(floor(index_pointer.g*255.0)) << uint(8));
		vec4 star_0 = texelFetch(stars,ivec2(int(star_index),0),0);
		vec4 star_1 = texelFetch(stars,ivec2(int(star_index),1),0);
		vec4 star_2 = texelFetch(stars,ivec2(int(star_index),2),0);
		vec4 star_3 = texelFetch(stars,ivec2(int(star_index),3),0);
		vec4 star_4 = texelFetch(stars,ivec2(int(star_index),4),0);
		vec4 star_5 = texelFetch(stars,ivec2(int(star_index),5),0);
		vec3 xym = shit(star_0.rgb,star_1.rgb,star_2.rgb,star_3.rgb);
		vec2 temp_neighbor = fuck(star_4.rgb,star_5.rgb);
		float true_x = xym.r/4.0-360.0;
		float true_y = xym.g/4.0-360.0;
		float true_m = xym.b/1000.0;
		//if (star_index == uint(0) && xym.r*255.0 > (146.0)) {
		//	COLOR = vec3(1,1,1);
		//}
		vec3 unit_dir = angle_to_unit_dir(radians(true_x),radians(true_y));
		min_distance = max(dot(unit_dir,EYEDIR),min_distance);
		if (dot(unit_dir,EYEDIR)>star_radius-(pow(true_m,powe)/division_thingy)) {
			in_star = true;
			//COLOR = texture(temp_gradient,vec2((temp_neighbor.r-1000.0)/39000.0,0.5)).rgb;
		} else {
			neighbor = uint(temp_neighbor.g);
		}
		
		}
		
		{
			
		uint star_index = neighbor;
		vec4 star_0 = texelFetch(stars,ivec2(int(star_index),0),0);
		vec4 star_1 = texelFetch(stars,ivec2(int(star_index),1),0);
		vec4 star_2 = texelFetch(stars,ivec2(int(star_index),2),0);
		vec4 star_3 = texelFetch(stars,ivec2(int(star_index),3),0);
		vec4 star_4 = texelFetch(stars,ivec2(int(star_index),4),0);
		vec4 star_5 = texelFetch(stars,ivec2(int(star_index),5),0);
		vec3 xym = shit(star_0.rgb,star_1.rgb,star_2.rgb,star_3.rgb);
		vec2 temp_neighbor = fuck(star_4.rgb,star_5.rgb);
		float true_x = xym.r/4.0-360.0;
		float true_y = xym.g/4.0-360.0;
		float true_m = xym.b/1000.0;
		//if (star_index == uint(0) && xym.r*255.0 > (146.0)) {
		//	COLOR = vec3(1,1,1);
		//}
		vec3 unit_dir = angle_to_unit_dir(radians(true_x),radians(true_y));
		min_distance = max(dot(unit_dir,EYEDIR),min_distance);
		if (dot(unit_dir,EYEDIR)>star_radius-(pow(true_m,powe)/division_thingy))  {
			star_temp = temp_neighbor.r;
			in_star = true;
			//COLOR = texture(temp_gradient,vec2((temp_neighbor.r-1000.0)/39000.0,0.5)).rgb;
		} else {
			float color = pow(texture(sky_thingy,SKY_COORDS).r/5.0,2);
		}
		
		}
		
		if (in_star) {
			COLOR = texture(temp_gradient,vec2((star_temp-1000.0)/39000.0,0.5)).rgb;
		} else {
			float color = pow(texture(sky_thingy,SKY_COORDS).r/2.5,3);
			COLOR = vec3(color*0.4,color*0.6,color*1.5);
			//COLOR += vec3(1.0/pow(((1.0*(1.0-min_distance))*10000000.0),1.1));
		}
		//COLOR = vec3(abs(true_x)/90.0);
	}
}
