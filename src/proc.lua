function planetShader()
	return love.graphics.newShader [[
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
	]]
end

function genTexture(d,a1,b1,a2,b2,r,g,b,ctype)
	local o = love.math.random(20000)
	local pi = math.pi
	data = love.image.newImageData(d,d)
	for x=0,d-1 do
		for y=0,d-1 do
			local s=x/d
			local t=y/d
			local dx=a2-a1
			local dy=b2-b1
			local nx=a1+math.cos(s*2*pi)*dx/(2*pi)
        	local ny=b1+math.cos(t*2*pi)*dy/(2*pi)
        	local nz=a1+math.sin(s*2*pi)*dx/(2*pi)
        	local nw=b1+math.sin(t*2*pi)*dy/(2*pi)
        	c = love.math.noise(nx+o,ny+o,nz+o,nw+o)*255
        	if ctype == 0 then data:setPixel(x, y, r, g, c, 255)
        	elseif ctype == 1 then data:setPixel(x, y, c, g, b, 255)
        	elseif ctype == 2 then data:setPixel(x, y, r, c, b, 255)
        	end
		end
	end
	return love.graphics.newImage(data)
end

function createSol(type)
	curSize = 500
	return {
		type = type,
		name = "",
		size = curSize,
		texture = genTexture(curSize,0,0,1,1,100,100,100,0),
		xrot = 0,
		yrot = 0,
		xrotspd = math.random()/5,
		yrotspd = math.random()/5
	}
end

function createPlanet(index,type)
	local curSize = math.random(100)+50
	local curDist,curVel
	if index == 0 then
			curDist = 340+math.random(20)+curSize
			curVel = 0.005+math.random(6)/1000+math.random(10)/10000
		else
			curDist = planets[index-1].distance+planets[index-1].size*math.random(2,3)+curSize+math.random(100)
			curVel = planets[index-1].velocity/1.4
		end
	return {
		type = type,
		name = "",
		size = curSize,
		texture = genTexture(curSize,math.random(10),math.random(10),math.random(20)+10,math.random(20)+10,math.random(200)+55,math.random(200)+55,math.random(200)+55,math.random(2)),
		x = 0,
		y = 0,
		xrot = 0,
		yrot = 0,
		xrotspd = math.random()/2,
		yrotspd = math.random()/2,
		distance = curDist,
		velocity = curVel,
		path = math.random(100)
	}
end
